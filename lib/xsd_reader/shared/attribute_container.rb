module XsdReader
  module AttributeContainer

    # Nested attributes
    # @!attribute attributes
    # @return [Array<Attribute>]

    # Nested attribute groups
    # @!attribute attribute_groups
    # @return [Array<AttributeGroup>]
    def self.included(obj)
      obj.child :attributes, [Attribute]
      obj.child :attribute_groups, [AttributeGroup]
    end
  end
end