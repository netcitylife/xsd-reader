module XsdReader
  # Base object
  class BaseObject
    attr_reader :options, :properties, :children, :links

    # Optional. Specifies a unique ID for the element
    # @!attribute id
    # @return [String]
    property :id, :string

    # Optional. Specifies the name of the attribute. Name and ref attributes cannot both be present
    # @!attribute name
    # @return [String]
    property :name, :string

    def initialize(options = {})
      @options    = options
      @properties = {}
      @children   = {}
      @links      = {}
      @cache      = {}

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
          result = result.all_attributes.find { |attr| attr.name == curname.sub(/^@/, '') }
        else
          result = result.all_elements.find { |elem| elem.name == curname }
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

    # Get all available elements on the current stack level
    # @return [Array<Element>]
    def all_elements
      map_children('*').map { |obj| obj.is_a?(Element) ? obj : obj.all_elements }.flatten
    end

    # Get all available attributes on the current stack level
    # @return [Array<Attribute>]
    def all_attributes
      map_children('*').map { |obj| obj.is_a?(Attribute) ? obj : obj.all_attributes }.flatten
    end

    protected

    # Define new object property
    # @param [Symbol] name
    # @param [Symbol] type
    # @param [Hash] options
    def self.property(name, type, options = {}, &block)
      @properties[to_underscore(name)] = {
        name:    name,
        type:    type,
        resolve: block,
        **options
      }
    end

    # Define new object child
    # @param [Symbol] name
    # @param [Class<BaseObject>, Array<Class<BaseObject>>] type
    # @param [Hash] options
    def self.child(name, type, options = {})
      @children[to_underscore(name)] = {
        name: name,
        type: type,
        **options
      }
    end

    # Define new object child
    # @param [Symbol] name
    # @param [Class<BaseObject>] type
    # @param [Hash] options
    def self.link(name, type, options = {})
      @links[to_underscore(name)] = {
        name: name,
        type: type,
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

    def self.to_underscore(string)
      string.gsub(/([^A-Z])([A-Z]+)/, '\1_\2').downcase
    end

    def self.uncapitalize(string)
      string.sub(/^([A-Z])/) { $1.tr!('[A-Z]', '[a-z]') }
    end

    # Lookup for properties
    def method_missing(symbol, *args)

      # if object has reference - proxy call to target object
      if node['ref']
        return reference.send(symbol, *args)
      end

      @cache[symbol] ||=
        if (property = @properties[symbol])
          # get value
          value = property[:resolve] ? property[:resolve].call : node[property[:name]]
          if value.nil?
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
        elsif (child = @children[symbol])
          element = self.class.uncapitalize(child[:type].to_s)
          map_children(element)
        elsif (link = @links[symbol])
          element = self.class.uncapitalize(link[:type].to_s)
          name    = send(link[:property])
          object_by_name(element, name) if name
        else
          raise Error, "Tried to access unknown property #{symbol} on #{self.class.name}"
        end
    end
  end
end