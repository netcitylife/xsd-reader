module XsdReader
  # Provides object an ability to have simple type (nested or linked)
  module SimpleTyped

    # Get connected simple type
    # @return [SimpleType, nil]
    def simple_type
      @simple_type ||= type_attribute ? object_by_name('simpleType', type_attribute) : map_child('simpleType')
    end

    private

    # Get type attribute value
    # @return [String, nil]
    def type_attribute
      type
    end
  end
end