module XsdReader
  # XML Schema choice element allows only one of the elements contained in the <choice> declaration to be present
  # within the containing element.
  # Parent elements: group, choice, sequence, complexType, restriction (both simpleContent and complexContent),
  # extension (both simpleContent and complexContent)
  # https://www.w3schools.com/xml/el_choice.asp
  class Choice
    include Shared
    include MinMaxOccurs
  end
end