module XsdReader
  # The unique element defines that an element or an attribute value must be unique within the scope.
  # Parent elements: element
  # https://www.w3schools.com/xml/el_unique.asp
  class Unique < BaseObject

    # Get nested selector object
    # @!attribute selector
    # @return [Selector]
    child :selector, Selector

    # Get nested field objects
    # @!attribute fields
    # @return [Array<Field>]
    child :fields, [Field]
  end
end