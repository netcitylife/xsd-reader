module MinMaxOccurs

  # Optional. Specifies the minimum number of times the choice element can occur in the parent the element.
  # The value can be any number >= 0. Default value is 1
  # @return [Integer]
  def min_occurs
    node.attributes['minOccurs']&.value&.to_i || 1
  end

  # Optional. Specifies the maximum number of times the choice element can occur in the parent element.
  # The value can be any number >= 0, or if you want to set no limit on the maximum number, use the value "unbounded".
  # Default value is 1
  # @return [Integer, Symbol]
  def max_occurs
    val = node.attributes['maxOccurs']&.value || 1
    val == 'unbounded' ? :unbounded : val&.to_i
  end
end