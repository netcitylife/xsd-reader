module XsdReader
  # The schema element defines the root element of a schema.
  # Parent elements: NONE
  # https://www.w3schools.com/xml/el_schema.asp
  class Schema < BaseObject

    # Optional. The form for attributes declared in the target namespace of this schema. The value must be "qualified"
    # or "unqualified". Default is "unqualified". "unqualified" indicates that attributes from the target namespace
    # are not required to be qualified with the namespace prefix. "qualified" indicates that attributes from the target
    # namespace must be qualified with the namespace prefix
    property :attributeFormDefault, :string, optional: true, default: 'unqualified'

    # Optional. The form for elements declared in the target namespace of this schema. The value must be "qualified"
    # or "unqualified". Default is "unqualified". "unqualified" indicates that elements from the target namespace are
    # not required to be qualified with the namespace prefix. "qualified" indicates that elements from the target
    # namespace must be qualified with the namespace prefix
    property :elementFormDefault, :string, optional: true, default: 'unqualified'

    # Optional. Specifies the default value of the block attribute on element and complexType elements in the target
    # namespace. The block attribute prevents a complex type (or element) that has a specified type of derivation from
    # being used in place of this complex type. This value can contain #all or a list that is a subset of extension,
    # restriction, or substitution:
    #   extension - prevents complex types derived by extension
    #   restriction - prevents complex types derived by restriction
    #   substitution - prevents substitution of elements
    #   #all - prevents all derived complex types
    property :blockDefault, :string, optional: true

    # Optional. Specifies the default value of the final attribute on element, simpleType, and complexType elements in
    # the target namespace. The final attribute prevents a specified type of derivation of an element, simpleType, or
    # complexType element. For element and complexType elements, this value can contain #all or a list that is a subset
    # of extension or restriction. For simpleType elements, this value can additionally contain list and union:
    #   extension - prevents derivation by extension
    #   restriction - prevents derivation by restriction
    #   list - prevents derivation by list
    #   union - prevents derivation by union
    #   #all - prevents all derivation
    property :finalDefault, :string, optional: true

    # Optional. A URI reference of the namespace of this schema
    property :targetNamespace, :string, optional: true

    # Optional. Specifies the version of the schema
    property :version, :string, optional: true

    # A URI reference that specifies one or more namespaces for use in this schema. If no prefix is assigned, the schema
    # components of the namespace can be used with unqualified references
    property :xmlns, :string

    # Get global complex types
    # @return [Array<ComplexType>]
    def complex_types
      @complex_types ||= map_children('complexType')
    end

    # Get global simple types
    # @return [Array<SimpleType>]
    def simple_types
      @simple_types ||= map_children('simpleType')
    end

    # Get current schema object
    # @return [Schema]
    def schema
      self
    end

    def target_namespace_prefix
      return nil unless target_namespace
      namespaces.select { |k, v| v == target_namespace }.keys.first.sub('xmlns:', '')
    end

    # Get schema namespace prefix
    def namespace_prefix
      @namespace_prefix ||= [namespaces.find { |ns| ns[1] =~ /XMLSchema/ }&.split(':')[1], nil].uniq.join(':')
    end

    def namespaces
      self.node ? self.node.namespaces : {}
    end

    def targets_namespace?(ns)
      target_namespace == ns || target_namespace == namespaces["xmlns:#{ns}"]
    end

    def imports
      @imports ||= map_children("import")
    end

    # Override map_children on schema to get objects from all imported schemas
    # @param [String] xml_name
    # @return [Array]
    def map_children(xml_name)
      super + import_map_children(xml_name)
    end

    def import_map_children(xml_name)
      return [] if xml_name == 'import'
      imports.map { |import| import.reader.schema.map_children(xml_name) }.flatten
    end

    def import_by_namespace(ns)
      aliases = [ns, namespaces["xmlns:#{(ns || '').gsub(/^xmlns:/, '')}"]].compact
      imports.find { |import| aliases.include?(import.namespace) }
    end
  end
end