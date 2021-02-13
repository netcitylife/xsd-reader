module XsdReader
  # The extension element extends an existing simpleType or complexType element.
  # Parent elements: simpleContent, complexContent
  # https://www.w3schools.com/xml/el_extension.asp
  class Extension < BaseObject
    include Based
    include SimpleTyped
    include ComplexTyped

    private

    # Get type attribute value
    # @return [String, nil]
    def type_attribute
      nil
    end
  end
end