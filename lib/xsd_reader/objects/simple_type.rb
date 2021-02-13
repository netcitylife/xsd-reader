module XsdReader
  # The simpleType element defines a simple type and specifies the constraints and information about the values
  # of attributes or text-only elements.
  # Parent elements: attribute, element, list, restriction, schema, union
  # https://www.w3schools.com/xml/el_simpletype.asp
  class SimpleType < BaseObject

    # Nested restriction
    # @!attribute restriction
    # @return [Restriction, nil]
    child :restriction, Restriction

    # Nested union
    # @!attribute union
    # @return [Union, nil]
    child :union, Union

    # Nested list
    # @!attribute list
    # @return [List, nil]
    child :list, List

    # Determine if this is a linked type
    # @return [Boolean]
    def linked?
      !name.nil?
    end
  end
end