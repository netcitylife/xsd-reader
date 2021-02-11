module XsdReader
  # Provides object an ability to have simple type (nested or linked)
  module SimpleTyped

    # Get connected simple type
    # @return [SimpleType, nil]
    def simple_type
      @simple_type ||= link_attribute ? object_by_name('simpleType', link_attribute) : map_child('simpleType')
    end

    private

    def link_attribute
      type
    end
  end
end