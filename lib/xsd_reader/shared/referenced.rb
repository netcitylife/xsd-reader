module XsdReader
  module Referenced

    # Optional. Specifies a reference to a named attribute. Name and ref attributes cannot both be present.
    # If ref is present, simpleType element, form, and type cannot be present
    attribute :ref, :string, optional: true

    def referenced_object
      @referenced_object ||= object_by_name(self.class.name.split('::').last.downcase, ref) if ref
    end

    def all_elements
      referenced_object ? referenced_object.all_elements : super
    end

    def nested_elements
      referenced_object ? referenced_object.nested_elements : super
    end

    def attributes
      referenced_object ? referenced_object.attributes : super
    end

    def name
      super || referenced_object&.name
    end

    def type
      super || referenced_object&.type
    end
  end
end