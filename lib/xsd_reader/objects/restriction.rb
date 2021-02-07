module XsdReader
  # The restriction element defines restrictions on a simpleType, simpleContent, or complexContent definition.
  # Parent elements: simpleType, simpleContent, complexContent
  # https://www.w3schools.com/xml/el_restriction.asp
  class Restriction < BaseObject
    include Shared

    def restrictions
      nodes.inject({}) do |hash, node|
        key   = node.name
        value = node.attributes['value'].value

        if key == 'enumeration'
          hash[key]        ||= {}
          hash[key][value] = documentation_for(node)
        else
          hash[key] = value
        end
        hash
      end
    end

    # def fraction_digits
    #
    # end
    #
    # def enumeration
    #
    # end
    #
    # def max_exclusive
    #
    # end
    #
    # def min_exclusive
    #
    # end
    #
    # def max_inclusive
    #
    # end
    #
    # def min_inclusive
    #
    # end
    #
    # def length
    #
    # end
    #
    # def max_length
    #
    # end
    #
    # def min_length
    #
    # end
    #
    # def pattern
    #
    # end
    #
    # def total_digits
    #
    # end
    #
    # def white_space
    #
    # end
  end
end