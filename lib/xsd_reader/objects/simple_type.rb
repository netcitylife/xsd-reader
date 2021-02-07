module XsdReader
  # The simpleType element defines a simple type and specifies the constraints and information about the values
  # of attributes or text-only elements.
  # Parent elements: attribute, element, list, restriction, schema, union
  # https://www.w3schools.com/xml/el_simpletype.asp
  class SimpleType < BaseObject
    include Shared

    # Get nested restriction
    # @return [XsdReader::Restriction, nil]
    def restriction
      @restriction ||= map_children('restriction').first
    end

    # Get nested union
    # @return [XsdReader::Union, nil]
    def union
      @union ||= map_children('union').first
    end

    # TODO: add support for list
    # def list
    #
    # end
  end
end