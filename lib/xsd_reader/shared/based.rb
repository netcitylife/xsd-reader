module XsdReader
  # Used by extension and restriction elements
  module Based
    include AttributeContainer

    # Required. Specifies the name of a built-in data type, a simpleType element, or a complexType element
    # @!attribute base
    # @return [String]

    # Base complexType
    # @!attribute base_complex_type
    # @return [ComplexType, nil]

    # Base simpleType
    # @!attribute base_simple_type
    # @return [SimpleType, nil]
    def self.included(obj)
      obj.property :base, :string
      obj.link :base_complex_type, ComplexType, property: :base
      obj.link :base_simple_type, SimpleType, property: :base
    end
  end
end