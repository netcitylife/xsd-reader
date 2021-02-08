module XsdReader
  # The attribute element defines an attribute.
  # Parent elements: attributeGroup, schema, complexType, restriction (both simpleContent and complexContent), extension (both simpleContent and complexContent)
  # https://www.w3schools.com/xml/el_attribute.asp
  class Attribute < BaseObject
    include Shared
    include Referenced

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

    # Optional. Specifies a fixed value for the attribute. Default and fixed attributes cannot both be present
    # @return [String]
    def fixed
      node['fixed']
    end

    # Optional. Specifies how the attribute is used. Can be one of the following values:
    #     optional - the attribute is optional (this is default)
    #     prohibited - the attribute cannot be used
    #     required - the attribute is required
    # @return [String]
    def use
      node['use'] || 'optional'
    end
  end
end