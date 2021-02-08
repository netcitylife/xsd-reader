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
      node.attributes['id']&.value
    end

    #
    # Node to class mapping
    #
    def class_for(n)
      class_mapping = {
        "#{schema_namespace_prefix}schema"         => Schema,
        "#{schema_namespace_prefix}element"        => Element,
        "#{schema_namespace_prefix}attribute"      => Attribute,
        "#{schema_namespace_prefix}choice"         => Choice,
        "#{schema_namespace_prefix}complexType"    => ComplexType,
        "#{schema_namespace_prefix}sequence"       => Sequence,
        "#{schema_namespace_prefix}simpleContent"  => SimpleContent,
        "#{schema_namespace_prefix}complexContent" => ComplexContent,
        "#{schema_namespace_prefix}extension"      => Extension,
        "#{schema_namespace_prefix}import"         => Import,
        "#{schema_namespace_prefix}simpleType"     => SimpleType,
        "#{schema_namespace_prefix}all"            => All,
        "#{schema_namespace_prefix}restriction"    => Restriction,
        "#{schema_namespace_prefix}group"          => Group,
        "#{schema_namespace_prefix}any"            => Any,
        "#{schema_namespace_prefix}union"          => Union,
      }

      class_mapping[n.is_a?(Nokogiri::XML::Node) ? n.name : n]
    end

    # Получить объект ридера для XML ноды
    # @param [Nokogiri::XML::Node]
    # @return [BasicObject, nil]
    def node_to_object(node)
      # TODO: хранить соответствие ноды и объекта и возвращать уже созданные объекты при повторном запросе
      # if node

      fullname = [node.namespace ? node.namespace.prefix : nil, node.name].reject { |str| str.nil? || str == '' }.join(':')
      klass    = class_for(fullname)
      klass.nil? ? nil : klass.new(options.merge(node: node, schema: schema))
    end
  end
end