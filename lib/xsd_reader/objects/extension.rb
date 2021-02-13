module XsdReader
  # The extension element extends an existing simpleType or complexType element.
  # Parent elements: simpleContent, complexContent
  # https://www.w3schools.com/xml/el_extension.asp
  class Extension < BaseObject
    include Based
    include SimpleTyped
    include ComplexTyped
    include AttributeContainer

    private

    # Get type attribute value
    # @return [nil]
    def self.type_property
      nil
    end
  end
end