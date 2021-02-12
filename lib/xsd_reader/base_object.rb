module XsdReader
  class BaseObject

    attr_reader :options

    def initialize(opts = {})
      @options = opts || {}
      raise "#{self.class}.new expects a hash parameter" unless @options.is_a?(Hash)
    end

    def logger
      options[:logger]
    end

    # Get current XML node
    # @return Nokogiri::XML::Node
    def node
      options[:node]
    end

    def nodes
      node.xpath("./*")
    end

    # Optional. Specifies a unique ID for the element
    # @return [String, nil]
    def id
      node['id']
    end

    # Optional. Specifies the name of the node. Name and ref attributes cannot both be present
    # @return [String]
    def name
      node['name']
    end

    # Specifies a built-in data type or a simple/complex type.
    # The type attribute can only be present when the content does not contain a simpleType/complexType element
    # @return [String]
    def type
      node['type']
    end

    #
    # Node to class mapping
    #
    def class_for(n)
      class_mapping = {
        "#{schema_namespace_prefix}schema"          => Schema,
        "#{schema_namespace_prefix}element"         => Element,
        "#{schema_namespace_prefix}attribute"       => Attribute,
        "#{schema_namespace_prefix}choice"          => Choice,
        "#{schema_namespace_prefix}complexType"     => ComplexType,
        "#{schema_namespace_prefix}sequence"        => Sequence,
        "#{schema_namespace_prefix}simpleContent"   => SimpleContent,
        "#{schema_namespace_prefix}complexContent"  => ComplexContent,
        "#{schema_namespace_prefix}extension"       => Extension,
        "#{schema_namespace_prefix}import"          => Import,
        "#{schema_namespace_prefix}simpleType"      => SimpleType,
        "#{schema_namespace_prefix}all"             => All,
        "#{schema_namespace_prefix}restriction"     => Restriction,
        "#{schema_namespace_prefix}group"           => Group,
        "#{schema_namespace_prefix}any"             => Any,
        "#{schema_namespace_prefix}union"           => Union,
        "#{schema_namespace_prefix}attribute_group" => AttributeGroup,
        "#{schema_namespace_prefix}list"            => List,
        "#{schema_namespace_prefix}unique"          => Unique,
        "#{schema_namespace_prefix}selector"        => Selector,
        "#{schema_namespace_prefix}field"           => Field,
      }

      class_mapping[n.is_a?(Nokogiri::XML::Node) ? n.name : n]
    end

    # Search node by name in all available schemas and return its object
    # @param [String] node_name
    # @param [String] name
    # @return [BaseObject, nil]
    def object_by_name(node_name, name)

      # get prefix and local name
      if name.include?(':')
        name_prefix, name_local = name.split(':')
      else
        name_prefix = ''
        name_local  = name
      end

      # do not search in http://www.w3.org/2001/XMLSchema
      schema_prefix = schema_namespace_prefix[0..-2]
      return nil if schema_prefix == name_prefix

      # determine schema for namespace
      search_schema = schema_for_namespace(name_prefix) || schema
      return nil unless search_schema

      # find element in target schema
      namespace = { 'xs' => 'http://www.w3.org/2001/XMLSchema' }
      result    = search_schema.node.xpath("//xs:#{node_name}[@name=\"#{name_local}\"]", namespace).first

      result ? search_schema.node_to_object(result) : nil
    end

    # Get reader object for node
    # @param [Nokogiri::XML::Node]
    # @return [BasicObject, nil]
    def node_to_object(node)
      # TODO: хранить соответствие ноды и объекта и возвращать уже созданные объекты при повторном запросе
      # if node

      fullname = [node.namespace ? node.namespace.prefix : nil, node.name].reject { |str| str.nil? || str == '' }.join(':')
      klass    = class_for(fullname)
      klass.nil? ? nil : klass.new(options.merge(node: node, schema: schema))
    end

    # Get xml parent object
    # @return [self, nil]
    def parent
      node.respond_to?(:parent) && node.parent ? node_to_object(node.parent) : nil
    end

    def mappable_children(xml_name)
      node.xpath("./xs:#{xml_name}", { 'xs' => 'http://www.w3.org/2001/XMLSchema' }).to_a
    end

    def map_children(xml_name)
      mappable_children(xml_name).map { |current_node| node_to_object(current_node) }
    end

    # @return [BaseObject]
    def map_child(xml_name)
      map_children(xml_name).first
    end
  end
end