module XsdReader
  # The all element specifies that the child elements can appear in any order and that each child element can
  # occur zero or one time.
  # Parent elements: group, complexType, restriction (both simpleContent and complexContent),
  # extension (both simpleContent and complexContent)
  # https://www.w3schools.com/xml/el_all.asp
  class All < BaseObject
    include ElementContainer

    # Optional. Specifies the minimum number of times the element can occur. The value can be 0 or 1. Default value is 1
    property :minOccurs, :integer, optional: true, default: 1

    # Optional. Specifies the maximum number of times the element can occur. The value must be 1.
    property :maxOccurs, :integer, optional: true, default: 1
  end
end