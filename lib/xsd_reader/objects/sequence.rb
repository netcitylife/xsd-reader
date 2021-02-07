module XsdReader
  # The sequence element specifies that the child elements must appear in a sequence.
  # Each child element can occur from 0 to any number of times.
  # Parent elements: group, choice, sequence, complexType, restriction (both simpleContent and complexContent),
  # extension (both simpleContent and complexContent)
  # https://www.w3schools.com/xml/el_sequence.asp
  class Sequence < BaseObject
    include Shared
    include MinMaxOccurs
  end
end