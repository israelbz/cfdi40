module Cfdi40
  class Node
    # Nokigir XML Document for the xml_node
    attr_accessor :xml_document, :xml_parent, :children_nodes, :parent_node
    attr_writer :element_name

    def initialize
      self.class.verify_class_variables
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
      raise Error, 'child_node must be a Node object' unless child_node.is_a?(Node)

      child_node.parent_node = self
      @children_nodes << child_node
    end

    def current_namespace
      return unless self.class.respond_to?(:namespaces)
      if self.class.namespaces.empty?
        return parent_node.current_namespace unless parent_node.nil?
      end

      self.class.namespaces.keys.last
    end

    def create_xml_node
      # TODO: Quitar la siguiente linea (set_defaults) si funciona poniendo los defaults en initialize
      # set_defaults
      if self.respond_to?(:before_add, true)
        self.before_add
      end
      xml_node = xml_document.create_element(expanded_element_name)
      add_namespaces_to(xml_node)
      add_attributes_to(xml_node)
      add_children_to(xml_node)
      xml_parent.add_child xml_node
    end

    # Returns setted @element_name or use class_name
    def element_name
      return self.class.element_name unless self.class.element_name.nil? || self.class.element_name == ''

      self.class.name.split('::').last
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
        public_send(accessor).to_f == 0.0 ? '0' : sprintf("%0.6f", public_send(accessor).to_f)
      when :t_ImporteMXN
        public_send(accessor).to_f == 0.0 ? '0' : sprintf("%0.2f", public_send(accessor).to_f)
      else
        public_send(accessor)
      end
    end
  end
end
