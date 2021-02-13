module XsdReader
  # Used by extension and restriction elements
  module Based
    include AttributeContainer

    # Required. Specifies the name of a built-in data type, a simpleType element, or a complexType element
    # @return [String]
    property :base, :string

    # Get linked complexType
    # @return [ComplexType, nil]
    def base_complex_type
      @base_complex_type ||= object_by_name('complexType', base)
    end

    # Get linked simpleType
    # @return [SimpleType, nil]
    def base_simple_type
      @base_simple_type ||= object_by_name('simpleType', base)
    end
  end
end