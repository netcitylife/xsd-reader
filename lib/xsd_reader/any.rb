module XsdReader
  # The any element enables the author to extend the XML document with elements not specified by the schema.
  # Parent elements: choice, sequence
  # https://www.w3schools.com/xml/el_any.asp
  class Any
    include Shared
    include MinMaxOccurs

    # Optional. Specifies the namespaces containing the elements that can be used. Can be set to one of the following:
    #     ##any - elements from any namespace is allowed (this is default)
    #     ##other - elements from any namespace that is not the namespace of the parent element can be present
    #     ##local - elements must come from no namespace
    #     ##targetNamespace - elements from the namespace of the parent element can be present
    #     List of {URI references of namespaces, ##targetNamespace, ##local} - elements from a space-delimited list of
    #     the namespaces can be present
    # @return [String, nil]
    def namespace
      node.attributes['namespace']&.value
    end

    # Optional. Specifies how the XML processor should handle validation against the elements specified by this any
    # element. Can be set to one of the following:
    #   strict - the XML processor must obtain the schema for the required namespaces and validate the elements (this is default)
    #   lax - same as strict but; if the schema cannot be obtained, no errors will occur
    #   skip - The XML processor does not attempt to validate any elements from the specified namespaces
    # @return [String, nil]
    def process_contents
      node.attributes['processContents']&.value || 'strict'
    end
  end
end