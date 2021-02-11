module XsdReader
  # The list element defines a simple type element as a list of values of a specified data type.
  # Parent elements: simpleType
  # https://www.w3schools.com/xml/el_list.asp
  class List < BaseObject
    include Shared
    include SimpleTyped

    # Specifies the name of a built-in data type or simpleType element defined in this or another schema.
    # This attribute is not allowed if the content contains a simpleType element, otherwise it is required
    def item_type
      node['itemType']
    end

    def link_attribute
      item_type
    end
  end
end