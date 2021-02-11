module XsdReader
  # The simpleType element defines a simple type and specifies the constraints and information about the values
  # of attributes or text-only elements.
  # Parent elements: attribute, element, list, restriction, schema, union
  # https://www.w3schools.com/xml/el_simpletype.asp
  class SimpleType < BaseObject
    include Shared

    # Get nested restriction
    # @return [Restriction, nil]
    def restriction
      @restriction ||= map_child('restriction')
    end

    # Get nested union
    # @return [Union, nil]
    def union
      @union ||= map_child('union')
    end

    # Get nested list
    # @return [List, nil]
    def list
      @list ||= map_child('list')
    end

    # Determine if this is a linked type
    # @return [Boolean]
    def linked?
      !name.nil?
    end
  end
end