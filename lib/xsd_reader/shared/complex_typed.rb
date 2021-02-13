module XsdReader
  # Provides object an ability to have complex type (nested or linked)
  module ComplexTyped

    # Get connected complex type
    # @return [ComplexType, nil]
    def complex_type
      @complex_type ||= type_attribute ? object_by_name('complexType', type_attribute) : map_child('complexType')
    end

    private

    # Get type attribute value
    # @return [String, nil]
    def type_attribute
      type
    end
  end
end