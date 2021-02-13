module XsdReader
  # The restriction element defines restrictions on a simpleType, simpleContent, or complexContent definition.
  # Parent elements: simpleType, simpleContent, complexContent
  # https://www.w3schools.com/xml/el_restriction.asp
  class Restriction < BaseObject
    include Based
    include SimpleTyped
    include ComplexTyped
    include AttributeContainer

    FACET_ELEMENTS = %w[
      minExclusive minInclusive maxExclusive maxInclusive totalDigits
      fractionDigits length minLength maxLength enumeration whiteSpace pattern
    ].freeze

    # Get restriction facets
    # @return [Hash]
    def facets
      nodes.inject({}) do |hash, node|
        if FACET_ELEMENTS.include?(node.name)
          key   = node.name
          value = node['value']

          if key == 'enumeration'
            hash[key]        ||= {}
            hash[key][value] = documentation_for(node)
          else
            hash[key] = value
          end
        end
        hash
      end
    end

    private

    # Get type attribute value
    # @return [nil]
    def self.type_property
      nil
    end
  end
end