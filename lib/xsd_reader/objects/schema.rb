module XsdReader
  # The schema element defines the root element of a schema.
  # Parent elements: NONE
  # https://www.w3schools.com/xml/el_schema.asp
  class Schema < BaseObject
    include AttributeContainer
    include ElementContainer

    # Optional. The form for attributes declared in the target namespace of this schema. The value must be "qualified"
    # or "unqualified". Default is "unqualified". "unqualified" indicates that attributes from the target namespace
    # are not required to be qualified with the namespace prefix. "qualified" indicates that attributes from the target
    # namespace must be qualified with the namespace prefix
    # @!attribute attribute_form_default
    # @return [String]
    property :attributeFormDefault, :string, default: 'unqualified'

    # Optional. The form for elements declared in the target namespace of this schema. The value must be "qualified"
    # or "unqualified". Default is "unqualified". "unqualified" indicates that elements from the target namespace are
    # not required to be qualified with the namespace prefix. "qualified" indicates that elements from the target
    # namespace must be qualified with the namespace prefix
    # @!attribute element_form_default
    # @return [String]
    property :elementFormDefault, :string, default: 'unqualified'

    # Optional. Specifies the default value of the block attribute on element and complexType elements in the target
    # namespace. The block attribute prevents a complex type (or element) that has a specified type of derivation from
    # being used in place of this complex type. This value can contain #all or a list that is a subset of extension,
    # restriction, or substitution:
    #   extension - prevents complex types derived by extension
    #   restriction - prevents complex types derived by restriction
    #   substitution - prevents substitution of elements
    #   #all - prevents all derived complex types
    # @!attribute block_default
    # @return [String]
    property :blockDefault, :string

    # Optional. Specifies the default value of the final attribute on element, simpleType, and complexType elements in
    # the target namespace. The final attribute prevents a specified type of derivation of an element, simpleType, or
    # complexType element. For element and complexType elements, this value can contain #all or a list that is a subset
    # of extension or restriction. For simpleType elements, this value can additionally contain list and union:
    #   extension - prevents derivation by extension
    #   restriction - prevents derivation by restriction
    #   list - prevents derivation by list
    #   union - prevents derivation by union
    #   #all - prevents all derivation
    # @!attribute final_default
    # @return [String]
    property :finalDefault, :string

    # Optional. A URI reference of the namespace of this schema
    # @!attribute target_namespace
    # @return [String]
    property :targetNamespace, :string

    # Optional. Specifies the version of the schema
    # @!attribute version
    # @return [String]
    property :version, :string

    # A URI reference that specifies one or more namespaces for use in this schema. If no prefix is assigned, the schema
    # components of the namespace can be used with unqualified references
    # @!attribute xmlns
    # @return [String]
    property :xmlns, :string

    # Global complex types
    # @!attribute complex_types
    # @return [Array<ComplexType>]
    child :complex_types, [:complexType]

    # Global simple types
    # @!attribute simple_types
    # @return [Array<SimpleType>]
    child :simple_types, [:simpleType]

    # Global groups
    # @!attribute groups
    # @return [Array<Group>]
    child :groups, [:group]

    # Get nested groups
    # @!attribute imports
    # @return [Array<Import>]
    child :imports, [:import]

    # Get current schema object
    # @return [Schema]
    def schema
      self
    end

    # Get all available root elements. Overrides base implementation for better speed
    # @return [Array<Element>]
    def all_elements(*)
      elements
    end

    # Get all available root attributes. Overrides base implementation for better speed
    # @return [Array<Attribute>]
    def all_attributes(*)
      attributes
    end

    # Get target namespace prefix. There may be more than one prefix, but we return only first defined
    # @return [String]
    def target_namespace_prefix
      @target_namespace_prefix ||= namespaces.key(target_namespace)&.sub(/^xmlns:?/, '') || ''
    end

    # Get schema namespace prefix
    # @return [String]
    def namespace_prefix
      @namespace_prefix ||= namespaces.key(XML_SCHEMA).sub(/^xmlns:?/, '')
    end

    # Check if namespace is a target namespace
    # @param [String] prefix
    # @return [Boolean]
    def targets_namespace?(prefix)
      namespaces[prefix.empty? ? 'xmlns' : "xmlns:#{prefix}"] == target_namespace
    end

    # Override map_children on schema to get objects from all imported schemas
    # @param [Symbol] name
    # @return [Array<BaseObject>]
    def map_children(name, cache = {})
      super(name) + import_map_children(name, cache)
    end

    # Get children from all imported schemas
    # @param [Symbol] name
    # @return [Array<BaseObject>]
    # TODO: better recursion handling, may be refactor needed 1 reader for all schemas with centralized cache
    def import_map_children(name, cache)
      return [] if name.to_sym == :import

      imports.map do |import|
        if cache[import.namespace]
          reader.logger.debug(XsdReader) { "Schema '#{import.namespace}' already parsed, skiping" }
          nil
        else
          cache[import.namespace] = true
          import.imported_reader.schema.map_children(name, cache)
        end
      end.compact.flatten
    end

    def import_by_namespace(ns)
      aliases = [ns, namespaces["xmlns:#{(ns || '').gsub(/^xmlns:/, '')}"]].compact
      imports.find { |import| aliases.include?(import.namespace) }
    end
  end
end