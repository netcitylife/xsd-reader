module XsdReader
  module ElementContainer

    # Nested elements
    # @!attribute elements
    # @return [Array<Element>]
    def self.included(obj)
      obj.child :elements, [:element]
    end
  end
end