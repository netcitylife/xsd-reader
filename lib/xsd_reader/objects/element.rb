module XsdReader
  # The element element defines an element.
  # Parent elements: schema, choice, all, sequence, group
  # https://www.w3schools.com/xml/el_element.asp
  class Element < BaseObject
    TYPE_PROPERTY = :type

    include MinMaxOccurs
    include SimpleTyped
    include ComplexTyped
    include Referenced

    # Optional. Specifies the name of the attribute. Name and ref attributes cannot both be present
    # @!attribute name
    # @return [String]
    property :name, :string

    # Optional. Specifies either the name of a built-in data type, or the name of a simpleType or complexType element
    # @!attribute type
    # @return [String, nil]
    property :type, :string

    # Optional. Specifies the name of an element that can be substituted with this element. This attribute cannot be
    # used if the parent element is not the schema element
    # @!attribute substitution_group
    # @return [String, nil]
    property :substitutionGroup, :string

    # Optional. Specifies a default value for the element (can only be used if the element's content is a simple type
    # or text only)
    # @!attribute default
    # @return [String, nil]
    property :default, :string

    # Optional. Specifies a fixed value for the element (can only be used if the element's content is a simple type
    # or text only)
    # @!attribute fixed
    # @return [String, nil]
    property :fixed, :string

    # Optional. Specifies the form for the element. "unqualified" indicates that this element is not required to be
    # qualified with the namespace prefix. "qualified" indicates that this element must be qualified with the namespace
    # prefix. The default value is the value of the elementFormDefault attribute of the schema element. This attribute
    # cannot be used if the parent element is the schema element
    # @!attribute form
    # @return [String]
    property :form, :string

    # Optional. Specifies whether an explicit null value can be assigned to the element. True enables an instance of
    # the element to have the null attribute set to true. The null attribute is defined as part of the XML Schema
    # namespace for instances. Default is false
    # @!attribute nillable
    # @return [Boolean]
    property :nillable, :boolean, default: false

    # Optional. Specifies whether the element can be used in an instance document. True indicates that the element
    # cannot appear in the instance document. Instead, another element whose substitutionGroup attribute contains the
    # qualified name (QName) of this element must appear in this element's place. Default is false
    # @!attribute abstract
    # @return [Boolean]
    property :abstract, :boolean, default: false

    # Optional. Prevents an element with a specified type of derivation from being used in place of this element.
    # This value can contain #all or a list that is a subset of extension, restriction, or equivClass:
    #     extension    - prevents elements derived by extension
    #     restriction  - prevents elements derived by restriction
    #     substitution - prevents elements derived by substitution
    #     #all         - prevents all derived elements
    # @!attribute block
    # @return [String, nil]
    property :block, :string

    # Optional. Sets the default value of the final attribute on the element element. This attribute cannot be used if
    # the parent element is not the schema element. This value can contain #all or a list that is a subset of extension
    # or restriction:
    #     extension   - prevents elements derived by extension
    #     restriction - prevents elements derived by restriction
    #     #all        - prevents all derived elements
    # @!attribute final
    # @return [String, nil]
    property :final, :string

    # Nested unique objects
    # @!attribute unique
    # @return [Array<Unique>]
    child :unique, [:unique]

    # Determine if element is required
    # @return [Boolean]
    def required?
      # check local min_occurs first
      return false if min_occurs == 0

      # then iterate parents and check their min_occurs or choice
      obj = self
      loop do
        parent = obj.parent
        break unless parent.is_a?(MinMaxOccurs)
        return false if parent.is_a?(Choice) || parent.min_occurs == 0
        obj = parent
      end

      true
    end

    # Determine if element is optional
    # @return [Boolean]
    def optional?
      !required?
    end

    # Determine if element may occur multiple times
    # @return [Boolean]
    def multiple_allowed?
      # check local max_occurs first
      return true if max_occurs == :unbounded || max_occurs > 1

      # then iterate parents and check their max_occurs
      obj = self
      loop do
        parent = obj.parent
        break unless parent.is_a?(MinMaxOccurs)
        return true if parent.max_occurs == :unbounded || parent.max_occurs > 1
        obj = parent
      end

      false
    end

    # Determine if element has complex content
    # @return [Boolean]
    def complex?
      complex_type && !complex_type.simple_content && all_elements.any?
    end

    # Get elements that can appear instead of this one
    # @return [Array<Element>]
    def substitution_elements
      # TODO: for now we do not search in parent schemas (that imported current schema)
      # TODO: refactor for better namespace handling (use xpath with namespaces or correct comparison)
      schema.all_elements.select do |element|
        element.substitution_group&.split(':')&.last == name
      end
    end
  end
end
