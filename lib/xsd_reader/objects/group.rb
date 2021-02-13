module XsdReader
  # The group element is used to define a group of elements to be used in complex type definitions.
  # Parent elements: schema, choice, sequence, complexType, restriction (both simpleContent and complexContent),
  # extension (both simpleContent and complexContent)
  # https://www.w3schools.com/xml/el_group.asp
  class Group < BaseObject
    include MinMaxOccurs
    include Referenced

    # Get nested all object
    # @return [All]
    def all
      @all ||= map_child('all')
    end

    # Get nested choice object
    # @return [Choice]
    def choice
      @choice ||= map_child('choice')
    end

    # Get nested sequence object
    # @return [Sequence]
    def sequence
      @sequence ||= map_child('sequence')
    end
  end
end