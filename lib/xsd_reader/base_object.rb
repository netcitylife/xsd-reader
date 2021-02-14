module XsdReader
  # Base object
  class BaseObject
    attr_reader :options

    class << self
      attr_reader :properties, :children, :links

      def properties
        @properties ||= {}
      end

      def links
        @links ||= {}
      end

      def children
        @children ||= {}
      end
    end

    # Optional. Specifies a unique ID for the element
    # @!attribute id
    # @return [String]
    # property :id, :string

    def initialize(options = {})
      @options = options
      @cache   = {}

      raise Error, "#{self.class}.new expects a hash parameter" unless @options.is_a?(Hash)
    end

    # Get current XML node
    # @return [Nokogiri::XML::Node]
    def node
      options[:node]
    end

    # Get child nodes
    # @param [Symbol] name
    # @return [Nokogiri::XML::NodeSet]
    def nodes(name = :*)
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
        raise Error, "Schema not found for namespace '#{prefix}' in '#{schema.id || schema.target_namespace}'"
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
          result = result.all_attributes.find { |attr| attr.name == curname.sub(/^@/, '') }
        else
          result = result.all_elements.find { |elem| elem.name == curname }
        end
      end

      result
    end

    # Search node by name in all available schemas and return its object
    # @param [Symbol] node_name
    # @param [String] name
    # @return [BaseObject, nil]
    def object_by_name(node_name, name)

      # get prefix and local name
      name_prefix = get_prefix(name)
      name_local  = strip_prefix(name)

      # do not search for built-in types
      return nil if schema.namespace_prefix == name_prefix

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
    # @param [Symbol] name
    # @return [Array<BaseObject>]
    def map_children(name)
      nodes(name).map { |node| node_to_object(node) }
    end

    # Get child object
    # @param [Symbol] name
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

    # Get all available elements on the current stack level
    # @return [Array<Element>]
    def all_elements
      map_children(:*).map { |obj| obj.is_a?(Element) ? obj : obj.all_elements }.flatten
    end

    # Get all available attributes on the current stack level
    # @return [Array<Attribute>]
    def all_attributes
      map_children(:*).map { |obj| obj.is_a?(Attribute) ? obj : obj.all_attributes }.flatten
    end

    # Get reader instance
    # @return [XML]
    def reader
      options[:reader]
    end

    protected

    def self.to_underscore(string)
      string.to_s.gsub(/([^A-Z])([A-Z]+)/, '\1_\2').downcase.to_sym
    end

    # Define new object property
    # @param [Symbol] name
    # @param [Symbol] type
    # @param [Hash] options
    def self.property(name, type, options = {}, &block)
      properties[to_underscore(name)] = {
        name:    name,
        type:    type,
        resolve: block,
        **options
      }
    end

    # Define new object child
    # @param [Symbol] name
    # @param [Symbol, Array<Symbol>] type
    # @param [Hash] options
    def self.child(name, type, options = {})
      children[to_underscore(name)] = {
        type: type,
        **options
      }
    end

    # Define new object child
    # @param [Symbol] name
    # @param [Symbol] type
    # @param [Hash] options
    def self.link(name, type, options = {})
      links[to_underscore(name)] = {
        type: type,
        **options
      }
    end

    # Lookup for properties
    def method_missing(symbol, *args)

      # if object has reference - proxy call to target object
      if node['ref']
        return reference.send(symbol, *args)
      end

      # check cache first
      return @cache[symbol] if @cache[symbol]

      if (property = self.class.properties[symbol])
        # get value
        value  = property[:resolve] ? property[:resolve].call : node[property[:name]]
        result = if value.nil?
                   property[:default]
                 else
                   case property[:type]
                   when :integer
                     property[:name] == :maxOccurs && value == 'unbounded' ? :unbounded : value.to_i
                   when :boolean
                     !!value
                   else
                     value
                   end
                 end
        return @cache[symbol] = result
      end

      if (link = self.class.links[symbol])
        if (name = send(link[:property]))
          return @cache[symbol] = object_by_name(link[:type], name)
        end
      end

      if (child = self.class.children[symbol])
        result = child[:type].is_a?(Array) ? map_children(child[:type][0]) : map_child(child[:type])
        return @cache[symbol] = result
      end

      super
      # api = self.class.properties.keys + self.class.links.keys + self.class.children.keys
      # raise Error, "Tried to access unknown object '#{symbol}' on '#{self.class.name}'. Available options are: #{api}"
    end
  end
end
