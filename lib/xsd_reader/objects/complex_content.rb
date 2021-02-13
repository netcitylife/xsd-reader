module XsdReader
  # The complexContent element defines extensions or restrictions on a complex type that contains mixed content or elements only.
  # Parent elements: complexType
  # https://www.w3schools.com/xml/el_complexcontent.asp
  class ComplexContent < BaseObject

    # Optional. Specifies whether character data is allowed to appear between the child elements of this complexType
    # element. Default is false
    # @return [Boolean]
    property :mixed, :boolean, optional: true, default: false

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