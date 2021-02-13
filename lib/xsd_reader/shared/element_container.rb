module XsdReader
  module ElementContainer

    # Nested elements
    # @!attribute elements
    # @return [Array<Element>]
    def self.included(obj)
      obj.child :elements, [Element]
    end
  end
end