module XsdReader
  # The element element defines an element.
  # Parent elements: schema, choice, all, sequence, group
  # https://www.w3schools.com/xml/el_element.asp
  class Element < BaseObject
    include MinMaxOccurs
    include SimpleTyped
    include ComplexTyped
    include Referenced

    # Optional. Specifies either the name of a built-in data type, or the name of a simpleType or complexType element
    # @return [String, nil]
    property :type, :string, optional: true

    # Optional. Specifies the name of an element that can be substituted with this element. This attribute cannot be
    # used if the parent element is not the schema element
    # @return [String, nil]
    property :substitutionGroup, :string, optional: true

    # Optional. Specifies a default value for the element (can only be used if the element's content is a simple type
    # or text only)
    # @return [String, nil]
    property :default, :string, optional: true

    # Optional. Specifies a fixed value for the element (can only be used if the element's content is a simple type
    # or text only)
    # @return [String, nil]
    property :fixed, :string, optional: true

    # Optional. Specifies the form for the element. "unqualified" indicates that this element is not required to be
    # qualified with the namespace prefix. "qualified" indicates that this element must be qualified with the namespace
    # prefix. The default value is the value of the elementFormDefault attribute of the schema element. This attribute
    # cannot be used if the parent element is the schema element
    # @return [String]
    property :form, :string, optional: true

    # Optional. Specifies whether an explicit null value can be assigned to the element. True enables an instance of
    # the element to have the null attribute set to true. The null attribute is defined as part of the XML Schema
    # namespace for instances. Default is false
    # @return [Boolean]
    property :nillable, :boolean, optional: true, default: false

    # Optional. Specifies whether the element can be used in an instance document. True indicates that the element
    # cannot appear in the instance document. Instead, another element whose substitutionGroup attribute contains the
    # qualified name (QName) of this element must appear in this element's place. Default is false
    # @return [Boolean]
    property :abstract, :boolean, optional: true, default: false

    # Optional. Prevents an element with a specified type of derivation from being used in place of this element.
    # This value can contain #all or a list that is a subset of extension, restriction, or equivClass:
    #     extension    - prevents elements derived by extension
    #     restriction  - prevents elements derived by restriction
    #     substitution - prevents elements derived by substitution
    #     #all         - prevents all derived elements
    # @return [String, nil]
    property :block, :string, optional: true

    # Optional. Sets the default value of the final attribute on the element element. This attribute cannot be used if
    # the parent element is not the schema element. This value can contain #all or a list that is a subset of extension
    # or restriction:
    #     extension   - prevents elements derived by extension
    #     restriction - prevents elements derived by restriction
    #     #all        - prevents all derived elements
    # @return [String, nil]
    property :final, :string, optional: true

    # Get nested unique objects
    # @return [Array<Unique>]
    def unique
      @unique ||= map_children('unique')
    end

    # Get all attributes available on element
    # @return [Array<Attribute>]
    def all_attributes
      @attributes ||= complex_type&.attributes || []
    end

    # Determine if element is required
    # TODO: consider parent node group/sequence/choice/all min/max occurs
    # @return [Boolean]
    def required?
      minOccurs > 0 && !choice?
    end

    # Determine if element is optional
    # @return [Boolean]
    def optional?
      !required?
    end

    # Determine if element may occur multiple times
    # TODO: consider parent node group/sequence/choice/all min/max occurs
    # @return [Boolean]
    def multiple_allowed?
      maxOccurs == :unbounded || maxOccurs > 1
    end

    # Determine if element is inside choice
    def choice?
      obj = self
      loop do
        parent = obj.parent
        return true if parent.is_a?(Choice)
        break if parent.is_a?(ComplexType) || parent.is_a?(Schema)
        obj = parent
      end
      false
    end
  end
end
