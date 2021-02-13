module XsdReader
  # Provides object an ability to have complex type (nested or linked)
  module ComplexTyped

    # Child/linked complex type
    # @!attribute complex_type
    # @return [ComplexType, nil]
    def self.included(obj)
      obj.child :complex_type, ComplexType
      obj.link :complex_type, ComplexType, property: obj.type_property
    end
  end
end