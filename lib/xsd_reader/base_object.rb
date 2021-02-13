module XsdReader
  # Base object
  class BaseObject
    attr_reader :options, :properties

    # Optional. Specifies a unique ID for the element
    property :id, :string, optional: true

    # Optional. Specifies the name of the attribute. Name and ref attributes cannot both be present
    property :name, :string, optional: true

    def initialize(options = {})
      @options    = options
      @properties = {}

      raise Error, "#{self.class}.new expects a hash parameter" unless @options.is_a?(Hash)
    end

    # Get current XML node
    # @return [Nokogiri::XML::Node]
    def node
      options[:node]
    end

    # Get child nodes
    # @return [Nokogiri::XML::NodeSet]
    def nodes(name = '*')
      node.xpath("./xs:#{name}", { 'xs' => 'http://www.w3.org/2001/XMLSchema' })
    end

    # Get schema object for specified namespace prefix
    # @param [String] prefix
    # @return [Schema]
    def schema_for_namespace(prefix)
      if schema.targets_namespace?(prefix)
        schema
      elsif (import = schema.import_by_namespace(prefix))
        import.reader.schema
      else
        raise Error, "Schema not found for namespace '#{prefix}' in '#{schema.id || schema.targetNamespace}'"
      end
    end

    # Get element or attribute by path
    # @return [Element, Attribute, nil]
    def [](*args)
      result = self

      args.flatten.each do |curname|
        next if result.nil?
        curname = curname.to_s

        if curname =~ /^@/
          result = result.attributes.find { |attr| attr.name == curname.sub(/^@/, '') }
        else
          result = result.elements.find { |elem| elem.name == curname }
        end
      end

      result
    end

    # Search node by name in all available schemas and return its object
    # @param [String] node_name
    # @param [String] name
    # @return [BaseObject, nil]
    def object_by_name(node_name, name)

      # get prefix and local name
      name_prefix = get_prefix(name)
      name_local  = strip_prefix(name)

      # do not search for built-in types
      schema_prefix = schema.namespace_prefix[0..-2]
      return nil if schema_prefix == name_prefix

      # determine schema for namespace
      search_schema = name_prefix ? schema_for_namespace(name_prefix) : schema

      # find element in target schema
      namespace = { 'xs' => 'http://www.w3.org/2001/XMLSchema' }
      result    = search_schema.node.xpath("//xs:#{node_name}[@name=\"#{name_local}\"]", namespace).first

      result ? search_schema.node_to_object(result) : nil
    end

    # Get reader object for node
    # @param [Nokogiri::XML::Node]
    # @return [BaseObject]
    def node_to_object(node)
      # check object in cache first
      # TODO: проверить работу!
      return reader.object_cache[node.object_id] if reader.object_cache[node.object_id]

      klass = XML::CLASS_MAP[node.name]
      raise Error, "Object class not found for '#{node.name}'" unless klass

      reader.object_cache[node.object_id] = klass.new(options.merge(node: node, schema: schema))
    end

    # Get xml parent object
    # @return [BaseObject, nil]
    def parent
      node.respond_to?(:parent) && node.parent ? node_to_object(node.parent) : nil
    end

    # Get current schema object
    # @return [Schema]
    def schema
      options[:schema]
    end

    # Get child objects
    # @param [String] name
    # @return [Array<BaseObject>]
    def map_children(name)
      nodes(name).map { |node| node_to_object(node) }
    end

    # Get child object
    # @param [String] name
    # @return [BaseObject, nil]
    def map_child(name)
      map_children(name).first
    end

    # Strip namespace prefix from node name
    # @param [String, nil] name Name to strip from
    # @return [String, nil]
    def strip_prefix(name)
      name&.include?(':') ? name.split(':').last : name
    end

    # Get namespace prefix from node name
    # @param [String, nil] name Name to strip from
    # @return [String, nil]
    def get_prefix(name)
      name&.include?(':') ? name.split(':').first : name
    end

    # Return element documentation
    # @return [Array<String>]
    def documentation
      documentation_for(node)
    end

    # Return documentation for specified node
    # @param [Nokogiri::Xml::Node] node
    # @return [Array<String>]
    def documentation_for(node)
      node.xpath('./xs:annotation/xs:documentation/text()', { 'xs' => 'http://www.w3.org/2001/XMLSchema' }).map(&:to_s).map(&:strip)
    end

    def elements
      direct_elements
    end

    # Get all direct child elements
    def direct_elements
      @direct_elements ||= map_children("element")
    end

    # Get all nested elements
    def nested_elements
      # loop over each interpretable child xml node, and if we can convert a child node
      # to an XsdReader object, let it give its compilation of all_elements
      nodes.map { |node| node_to_object(node) }.compact.map do |obj|
        obj.is_a?(Element) ? obj : obj.nested_elements
      end.flatten
    end

    # Get all elements, including
    def all_elements
      @all_elements ||= nested_elements + (linked_complex_type&.all_elements || [])
    end

    protected

    # Define new object property
    # @param [Symbol] name
    # @param [Symbol] type
    # @param [Hash] options
    def self.property(name, type, options = {}, &block)
      @properties[name] = {
        name:    name,
        type:    type,
        resolve: block,
        **options
      }
    end

    # Get reader instance
    # @return [XML]
    def reader
      options[:reader]
    end

    # Get logger instance
    # @return [Logger]
    def logger
      reader.logger
    end

    private

    # Lookup for properties
    def method_missing(symbol, *args)
      property = @properties[symbol]

      if property
        # call if block was provided
        return property[:resolve].call if property[:resolve]

        value = node[property[:name]]
        return property[:default] if value.nil?

        case property[:type]
        when :integer
          return property == :maxOccurs && value == 'unbounded' ? :unbounded : value.to_i
        when :boolean
          return !!value
        else
          return value
        end
      end

      raise Error, "Tried to access unknown property #{symbol} on #{self.class.name}"
    end
  end
end