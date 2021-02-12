module XsdReader
  # The restriction element defines restrictions on a simpleType, simpleContent, or complexContent definition.
  # Parent elements: simpleType, simpleContent, complexContent
  # https://www.w3schools.com/xml/el_restriction.asp
  class Restriction < BaseObject
    include Shared
    include Based
    include SimpleTyped

    FACET_ELEMENTS = %w[
      minExclusive minInclusive maxExclusive maxInclusive totalDigits
      fractionDigits length minLength maxLength enumeration whiteSpace pattern
    ].freeze

    # Get restriction facets
    # @return [Hash]
    def facets
      nodes.inject({}) do |hash, node|
        next unless FACET_ELEMENTS.include?(node.name)
        key   = node.name
        value = node['value']

        if key == 'enumeration'
          hash[key]        ||= {}
          hash[key][value] = documentation_for(node)
        else
          hash[key] = value
        end
        hash
      end
    end

    private

    def link_attribute
      nil
    end
  end
end