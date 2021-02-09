module XsdReader
  # The simpleContent element contains extensions or restrictions on a text-only complex type or on a simple type as
  # content and contains no elements.
  # Parent elements: complexType
  # https://www.w3schools.com/xml/el_simpleContent.asp
  class SimpleContent < BaseObject
    include Shared

    # Get nested extension
    # @return [Extension, nil]
    def extension
      @extension ||= map_children('extension').first
    end

    # Get nested restriction
    # @return [Restriction, nil]
    def restriction
      @restriction ||= map_children('restriction').first
    end

    # Get all attributes defined extension or restriction
    # @return [Array<Attribute>]
    def attributes
      # TODO: restriction
      @attributes ||= extension&.attributes || []
    end
  end
end