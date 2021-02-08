module XsdReader
  module Referenced

    # Optional. Specifies a reference to a named object. Name and ref attributes cannot both be present.
    # If ref is present, simpleType element, form, and type cannot be present
    # @return [String]
    def ref
      node['ref']
    end

    def referenced_element
      @referenced_element ||= object_by_name(self.class.name.split('::').last.downcase, ref) if ref
    end

    def name
      super || referenced_element&.name
    end

    def type
      super || referenced_element&.type
    end
  end
end