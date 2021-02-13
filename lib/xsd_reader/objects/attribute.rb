module XsdReader
  # The attribute element defines an attribute.
  # Parent elements: attributeGroup, schema, complexType, restriction (both simpleContent and complexContent),
  # extension (both simpleContent and complexContent)
  # https://www.w3schools.com/xml/el_attribute.asp
  class Attribute < BaseObject
    include SimpleTyped
    include Referenced

    # Optional. Specifies a default value for the attribute. Default and fixed attributes cannot both be present
    # @return [String, nil]
    property :default, :string, optional: true

    # Optional. Specifies a fixed value for the attribute. Default and fixed attributes cannot both be present
    # @return [String, nil]
    property :fixed, :string, optional: true

    # Optional. Specifies the form for the attribute. The default value is the value of the attributeFormDefault
    # attribute of the element containing the attribute. Can be set to one of the following:
    #   qualified   - indicates that this attribute must be qualified with the namespace prefix and the no-colon-name
    #                 (NCName) of the attribute
    #   unqualified - indicates that this attribute is not required to be qualified with the namespace prefix and is
    #                 matched against the (NCName) of the attribute
    # @return [String, nil]
    # TODO: поддержка default значения с вычислением родителя
    property :form, :string, optional: true

    # Optional. Specifies a built-in data type or a simple type. The type attribute can only be present when the
    # content does not contain a simpleType element
    # @return [String, nil]
    property :type, :string, optional: true

    # Optional. Specifies how the attribute is used. Can be one of the following values:
    #   optional   - the attribute is optional (this is default)
    #   prohibited - the attribute cannot be used
    #   required   - the attribute is required
    # @return [String]
    property :use, :string, optional: true, default: 'optional'

    # Determine if attribute is required
    # @return [Boolean]
    def required?
      use == 'required'
    end

    # Determine if attribute is optional
    # @return [Boolean]
    def optional?
      use == 'optional'
    end

    # Determine if attribute is prohibited
    # @return [Boolean]
    def prohibited?
      use == 'prohibited'
    end
  end
end