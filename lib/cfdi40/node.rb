# frozen_string_literal: true

module Cfdi40
  # Main class for build CFDi.
  #
  # Keeps definitions (names, accessors and formats) and
  # relations (parent & children) between nodes
  class Node
    # Nokigiri XML Document for the xml_node
    attr_accessor :xml_document, :xml_parent, :children_nodes, :parent_node
    attr_writer :element_name
    attr_reader :readonly

    def initialize
      self.class.verify_class_variables
      @readonly = readonly
      @children_nodes = []
      set_defaults
    end

    # Use class variables to define attributes used to create nodes
    # Class variables are the same for children classes, so are organized by
    # the name of the class.
    def self.verify_class_variables
      @@attributes ||= {}
      @@attributes[name] ||= {}
      @@namespaces ||= {}
      @@namespaces[name] ||= {}
      @@default_values ||= {}
      @@default_values[name] ||= {}
      @@formats ||= {}
      @@formats[name] ||= {}
      @@element_names ||= {}
    end

    def self.define_attribute(accessor, xml_attribute:, default: nil, format: nil, readonly: false)
      verify_class_variables
      define_reader(accessor, format)
      define_writer(accessor, readonly, format)

      @@attributes[name][accessor.to_sym] = xml_attribute
      @@default_values[name][accessor.to_sym] = default if default
      return unless format

      @@formats[name][accessor.to_sym] = format.to_sym
    end

    def self.define_reader(accessor, format)
      case format.to_s
      when 't_Importe', 'decimal'
        define_method("#{accessor}".to_sym) do
          value = instance_variable_defined?("@#{accessor}".to_sym) ? instance_variable_get("@#{accessor}".to_sym) : 0
          value.to_f.round(6)
        end
      when 't_ImporteMXN'
        define_method("#{accessor}".to_sym) do
          value = instance_variable_defined?("@#{accessor}".to_sym) ? instance_variable_get("@#{accessor}".to_sym) : 0
          value.to_f.round(2)
        end
      when 't_FechaH', 't_FechaHora'
        define_method("#{accessor}".to_sym) do
          value = instance_variable_defined?("@#{accessor}".to_sym) ? instance_variable_get("@#{accessor}".to_sym) : nil
          return nil unless value.is_a?(Time)

          value
        end
      else
        define_method("#{accessor}".to_sym) do
          value = instance_variable_defined?("@#{accessor}".to_sym) ? instance_variable_get("@#{accessor}".to_sym) : nil
          return nil if value.nil?

          value.to_s
        end
      end
    end

    def self.define_writer(accessor, readonly_attribute, format)
      if readonly_attribute
        define_method "#{accessor}=".to_sym do |value|
          raise Cfdi40::Error, "attribute '#{accessor}' can not be modified"
        end
      else
        case format.to_s
        when 't_FechaH', 't_FechaHora'
          define_method "#{accessor}=".to_sym do |value|
            raise Cfdi40::Error, "CFDI is read only" if self.readonly

            clean_cached_xml
            if value.nil? || value.is_a?(Time)
              instance_variable_set("@#{accessor}".to_sym, value)
              return
            end

            begin
              parsed_time = Time.strptime(value.to_s, "%Y-%m-%dT%H:%M:%S")
              instance_variable_set("@#{accessor}".to_sym, parsed_time)
            rescue
              raise Cfdi40::Error, "#{value} must have format 'yyyy-mm-ddTHH:MM:SS'"
            end
          end
        else
          define_method "#{accessor}=".to_sym do |value|
            raise Cfdi40::Error, "CFDI loaded in read only mode" if self.readonly

            clean_cached_xml
            instance_variable_set("@#{accessor}".to_sym, value)
          end
        end
      end
    end

    def self.define_namespace(namespace, value)
      verify_class_variables
      @@namespaces[name][namespace] = value
    end

    def self.define_element_name(value)
      verify_class_variables
      @@element_names[name] = value.to_s
    end

    def self.namespaces
      @@namespaces[name]
    end

    def self.attributes
      @@attributes[name]
    end

    def self.default_values
      @@default_values[name]
    end

    def self.formats
      @@formats[name]
    end

    def self.element_name
      verify_class_variables
      @@element_names[name]
    end

    def set_defaults
      return if self.class.default_values.nil?

      self.class.default_values.each do |accessor, value|
        next unless attibute_is_null?(accessor)

        instance_variable_set "@#{accessor}".to_sym, value
      end
    end

    def attibute_is_null?(accessor)
      return true unless instance_variable_defined?("@#{accessor}".to_sym)

      instance_variable_get("@#{accessor}".to_sym).nil?
    end

    def add_child_node(child_node)
      raise Error, "child_node must be a Node object" unless child_node.is_a?(Node)

      child_node.parent_node = self
      @children_nodes << child_node
    end

    # Locks for readonly this node and children
    def lock
      @readonly = true
      @children_nodes.each(&:lock)

      true
    end

    def current_namespace
      return unless self.class.respond_to?(:namespaces)

      return parent_node.current_namespace if self.class.namespaces.empty? && !parent_node.nil?

      self.class.namespaces.keys.last
    end

    # Load attributes from a Nokogiri::XML::Element.
    # Attributes are loaded directly to the instance variable
    def load_from_ng_node(ng_node)
      # TODO: Se puede cargar el certificado
      # x509_cert = OpenSSL::X509::Certificate.new(Base64.decode64(<valor del atributo>))
      self.class.attributes.each do |variable_name, attr_name|
        next if ng_node.attributes[attr_name].nil?

        instance_variable_set("@#{variable_name}".to_sym, ng_node.attributes[attr_name].value)
      end
    end

    def create_xml_node
      before_add if respond_to?(:before_add, true)
      xml_node = xml_document.create_element(expanded_element_name)
      add_namespaces_to(xml_node)
      add_attributes_to(xml_node)
      add_children_to(xml_node)
      xml_parent.add_child xml_node
    end

    # Returns setted @element_name or use class_name
    def element_name
      return self.class.element_name unless self.class.element_name.nil? || self.class.element_name == ""

      self.class.name.split("::").last
    end

    def expanded_element_name
      return element_name unless current_namespace

      "#{current_namespace}:#{element_name}"
    end

    def add_namespaces_to(xml_node)
      self.class.namespaces.each do |namespace, value|
        xml_node.add_namespace namespace, value
      end
    end

    # Add defined attributes. Skip unused attributes
    def add_attributes_to(node)
      self.class.attributes.each do |object_accessor, xml_attribute|
        next unless respond_to?(object_accessor)
        next unless instance_variable_defined?("@#{object_accessor}".to_sym)
        next if instance_variable_get("@#{object_accessor}".to_sym).nil?

        node[xml_attribute] = formatted_value(object_accessor)
      end
    end

    def add_children_to(xml_node)
      children_nodes.each do |node|
        node.xml_document = xml_document
        node.xml_parent = xml_node
        node.create_xml_node
      end
    end

    def formatted_value(accessor)
      case self.class.formats[accessor]
      when :t_Importe, :decimal
        public_send(accessor).to_f == 0.0 ? "0" : format("%0.6f", public_send(accessor).to_f)
      when :t_ImporteMXN
        public_send(accessor).to_f == 0.0 ? "0" : format("%0.2f", public_send(accessor).to_f)
      when :t_FechaH, :t_FechaHora
        value = public_send(accessor)
        value.is_a?(Time) ? value.strftime("%Y-%m-%dT%H:%M:%S") : ''
      else
        public_send(accessor)
      end
    end

    # Cleans a Nokogiri object and/or loaded_xml string if exists
    def clean_cached_xml
      @docxml = nil
      @loaded_xml = nil

      parent_node&.clean_cached_xml
    end


  end
end
