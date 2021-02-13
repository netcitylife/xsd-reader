module XsdReader
  # The simpleContent element contains extensions or restrictions on a text-only complex type or on a simple type as
  # content and contains no elements.
  # Parent elements: complexType
  # https://www.w3schools.com/xml/el_simpleContent.asp
  class SimpleContent < BaseObject

    # Get nested extension
    # @return [Extension, nil]
    def extension
      @extension ||= map_child('extension')
    end

    # Get nested restriction
    # @return [Restriction, nil]
    def restriction
      @restriction ||= map_child('restriction')
    end
  end
end