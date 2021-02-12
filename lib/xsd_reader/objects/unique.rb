module XsdReader
  # The unique element defines that an element or an attribute value must be unique within the scope.
  # Parent elements: element
  # https://www.w3schools.com/xml/el_unique.asp
  class Unique < BaseObject
    include Shared

    # Get nested selector object
    # @return [Selector]
    def selector
      @selector ||= map_child('selector')
    end

    # Get nested field objects
    # @return [Array<Field>]
    def fields
      @fields ||= map_children('field')
    end
  end
end