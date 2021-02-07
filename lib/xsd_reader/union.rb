module XsdReader
  # The union element defines a simple type as a collection (union) of values from specified simple data types.
  # Parent elements: simpleType
  # https://www.w3schools.com/xml/el_union.asp
  class Union
    include Shared

    # Optional. Specifies a list of built-in data types or simpleType elements defined in a schema
    # @return [Array<String>]
    def member_types
      node.attributes['memberTypes']&.value&.split(' ') || []
    end

    # Get simple types that union points to
    # @return [Array<XsdReader::SimpleType>]
    def linked_simple_types
      @linked_simple_types ||= member_types.map do |name|
        object_by_name(prepend_namespace('simpleType'), name)
      end
    end
  end
end