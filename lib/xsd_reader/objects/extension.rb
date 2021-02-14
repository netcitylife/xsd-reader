module XsdReader
  # The extension element extends an existing simpleType or complexType element.
  # Parent elements: simpleContent, complexContent
  # https://www.w3schools.com/xml/el_extension.asp
  class Extension < BaseObject
    TYPE_PROPERTY = nil

    include Based
    include SimpleTyped
    include ComplexTyped
    include AttributeContainer
  end
end