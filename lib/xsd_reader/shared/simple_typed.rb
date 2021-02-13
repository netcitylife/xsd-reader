module XsdReader
  # Provides object an ability to have simple type (nested or linked)
  module SimpleTyped
    
    # Get child/linked simple type
    # @!attribute simple_type
    # @return [SimpleType, nil]
    def self.included(obj)
      obj.child :simple_type, SimpleType
      obj.link :simple_type, SimpleType, property: obj.type_property
    end
  end
end