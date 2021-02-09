module XsdReader
  # The attributeGroup element is used to group a set of attribute declarations so that they can be incorporated as a
  # group into complex type definitions.
  # Parent elements: attributeGroup, complexType, schema, restriction (both simpleContent and complexContent),
  # extension (both simpleContent and complexContent
  # https://www.w3schools.com/xml/el_attributegroup.asp
  class AttributeGroup < BaseObject
    include Shared
    include Referenced
    include Attributed
  end
end