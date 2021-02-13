module XsdReader
  # The union element defines a simple type as a collection (union) of values from specified simple data types.
  # Parent elements: simpleType
  # https://www.w3schools.com/xml/el_union.asp
  class Union < BaseObject

    # Optional. Specifies a list of built-in data types or simpleType elements defined in a schema
    # @return [Array<String>]
    property :memberTypes, :array, optional: true, default: [] do
      node['memberTypes']&.split(' ') || []
    end

    # Get nested simple types
    # @return [Array<SimpleType, String>]
    def types
      @types ||= map_children("simpleType") + memberTypes.map do |name|
        object_by_name('simpleType', name) || name
      end
    end
  end
end