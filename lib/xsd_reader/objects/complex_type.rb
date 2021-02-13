module XsdReader
  # The complexType element defines a complex type. A complex type element is an XML element that contains other
  # elements and/or attributes.
  # Parent elements: element, redefine, schema
  # https://www.w3schools.com/xml/el_complextype.asp
  class ComplexType < BaseObject
    include AttributeContainer

    # Optional. Specifies whether the complex type can be used in an instance document. True indicates that an element
    # cannot use this complex type directly but must use a complex type derived from this complex type. Default is false
    # @return [Boolean]
    property :abstract, :boolean, optional: true, default: false

    # Optional. Specifies whether character data is allowed to appear between the child elements of this complexType
    # element. Default is false. If a simpleContent element is a child element, the mixed attribute is not allowed!
    # @return [Boolean]
    property :mixed, :boolean, optional: true, default: false

    # Optional. Prevents a complex type that has a specified type of derivation from being used in place of this
    # complex type. This value can contain #all or a list that is a subset of extension or restriction:
    #   extension - prevents complex types derived by extension
    #   restriction - prevents complex types derived by restriction
    #   #all - prevents all derived complex types
    # @return [String, nil]
    property :block, :string, optional: true

    # Optional. Prevents a specified type of derivation of this complex type element. Can contain #all or a list
    # that is a subset of extension or restriction.
    #   extension - prevents derivation by extension
    #   restriction - prevents derivation by restriction
    #   #all - prevents all derivation
    # @return [String, nil]
    property :final, :string, optional: true

    # Simple content object
    # @return [SimpleContent]
    def simple_content
      @simple_content ||= map_child("simpleContent")
    end

    # Get complex content object
    # @return [ComplexContent]
    def complex_content
      @complex_content ||= map_child("complexContent")
    end

    # Get all attributes defined by type
    # @return [Array<Attribute>]
    def attributes
      if simple_content
        simple_content.attributes
      elsif complex_content
        complex_content.attributes
      else
        super
      end
    end

    # Determine if this is a linked type
    # @return [Boolean]
    def linked?
      # TODO: possibly additional check parent for type attribute
      !name.nil?
    end

    def elements
      all_elements
    end

    def parent_element
      if parent.nil? || parent.is_a?(Schema) || !parent.is_a?(Element)
        parent_elements.first
      end
    end

    def parent_elements
      elements_by_type(self.name)
    end
  end
end