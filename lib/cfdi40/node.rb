module Cfdi40
  class Node
    # Nokigir XML Document for the xml_node
    attr_accessor :xml_document, :xml_parent, :children_nodes

    def initialize
      self.class.verify_class_variables
      @children_nodes = []
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
    end

    def self.define_attribute(accessor, xml_attribute:, default: nil, format: nil, readonly: false)
      verify_class_variables
      if readonly
        attr_reader accessor.to_sym
      else
        attr_accessor accessor.to_sym
      end
      @@attributes[name][accessor.to_sym] = xml_attribute
      if default
        @@default_values[name][accessor.to_sym] = default
      end
      if format
        @@formats[name][accessor.to_sym] = format
      end
    end

    def self.define_namespace(namespace, value)
      verify_class_variables
      @@namespaces[name][namespace] = value
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

    def create_xml_node
      set_defaults
      if self.respond_to?(:before_add, true)
        self.before_add
      end
      xml_node = xml_document.create_element("cfdi:#{self.class.name.split('::').last}")
      add_namespaces_to(xml_node)
      add_attributes_to(xml_node)
      add_children_to(xml_node)
      xml_parent.add_child xml_node
    end

    def add_namespaces_to(xml_node)
      self.class.namespaces.each do |namespace, value|
        xml_node.add_namespace namespace, value
      end
    end

    def add_attributes_to(node)
      self.class.attributes.each do |object_accessor, xml_attribute|
        next unless respond_to?(object_accessor)
        next if public_send(object_accessor).nil?

        node[xml_attribute] = formated_value(object_accessor)
      end
    end

    def add_children_to(xml_node)
      children_nodes.each do |node|
        node.xml_document = xml_document
        node.xml_parent = xml_node
        node.create_xml_node
      end
    end

    def formated_value(accessor)
      case self.class.formats[accessor]
      when :t_Importe
        sprintf("%0.6f", public_send(accessor).to_f)
      else
        public_send(accessor)
      end
    end
  end
end
