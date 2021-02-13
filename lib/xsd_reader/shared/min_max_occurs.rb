module XsdReader
  module MinMaxOccurs

    # Optional. Specifies the minimum number of times the choice element can occur in the parent the element.
    # The value can be any number >= 0. Default value is 1
    # @return [Integer]
    property :minOccurs, :integer, optional: true, default: 1

    # Optional. Specifies the maximum number of times the choice element can occur in the parent element.
    # The value can be any number >= 0, or if you want to set no limit on the maximum number, use the value "unbounded".
    # Default value is 1
    # @return [Integer, Symbol]
    property :maxOccurs, :integer, optional: true, default: 1
  end
end