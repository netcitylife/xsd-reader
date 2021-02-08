module XsdReader
  # The group element is used to define a group of elements to be used in complex type definitions.
  # Parent elements: schema, choice, sequence, complexType, restriction (both simpleContent and complexContent),
  # extension (both simpleContent and complexContent)
  # https://www.w3schools.com/xml/el_group.asp
  class Group < BaseObject
    include Shared
    include MinMaxOccurs
  end
end