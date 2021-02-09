module XsdReader
  class Extension < BaseObject
    include Shared

    def base
      node['base']
    end

    def linked_complex_type
      @linked_complex_type ||= object_by_name('complexType', base) if base
    end

    def nested_elements
      (linked_complex_type&.nested_elements || []) + super
    end
  end
end