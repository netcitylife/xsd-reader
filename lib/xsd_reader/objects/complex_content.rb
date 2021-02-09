module XsdReader
  # The complexContent element defines extensions or restrictions on a complex type that contains mixed content or elements only.
  # Parent elements: complexType
  # https://www.w3schools.com/xml/el_complexcontent.asp
  class ComplexContent < BaseObject
    include Shared

    # Optional. Specifies whether character data is allowed to appear between the child elements of this complexType
    # element. Default is false
    # @return [Boolean]
    def mixed
      node['mixed'] == 'true'
    end

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