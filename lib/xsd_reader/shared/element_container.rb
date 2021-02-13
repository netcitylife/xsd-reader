module XsdReader
  module ElementContainer

    # Get nested elements
    # @return [Array<Element>]
    def elements
      @elements ||= map_children('elements')
    end
  end
end