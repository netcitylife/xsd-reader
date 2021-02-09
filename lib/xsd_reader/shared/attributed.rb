module XsdReader
  module Attributed

    # Get nested attribute groups
    # @return [Array<AttributeGroup>]
    def attribute_groups
      @attribute_groups ||= map_children('attributeGroup')
    end

    # Get nested attributes
    # @return [Array<Attribute>]
    def attributes
      @attributes ||= map_children('attribute')
      @attributes + attribute_groups.map(&:attributes).flatten
    end
  end
end