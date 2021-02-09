module XsdReader
  # Used by extension and restriction elements
  module Based
    include Attributed

    # Required. Specifies the name of a built-in data type, a simpleType element, or a complexType element
    # @return [String]
    def base
      node['base']
    end

    # Get base name without namespace prefix
    # @return [String, nil]
    def base_name
      base&.include?(':') ? base.split(':').last : nil
    end

    # Get base namespace prefix
    # @return [String, nil]
    def base_namespace
      base&.include?(':') ? base.split(':').first : nil
    end

    # Get linked complexType
    # @return [ComplexType, nil]
    def linked_complex_type
      @linked_complex_type ||= object_by_name('complexType', base) if base
    end

    # Get linked simpleType
    # @return [SimpleType, nil]
    def linked_simple_type
      @linked_simple_type ||= object_by_name('simpleType', base) if base
    end

    # Get all attributes defined by type
    # @return [Array<Attribute>]
    def attributes
      super + (linked_complex_type&.attributes || [])
    end

    def nested_elements
      (linked_complex_type&.nested_elements || []) + super
    end
  end
end