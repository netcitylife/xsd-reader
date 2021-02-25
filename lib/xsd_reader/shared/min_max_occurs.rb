module XsdReader
  module MinMaxOccurs

    # Optional. Specifies the minimum number of times the choice element can occur in the parent the element.
    # The value can be any number >= 0. Default value is 1
    # @!attribute min_occurs
    # @return [Integer]

    # Optional. Specifies the maximum number of times the choice element can occur in the parent element.
    # The value can be any number >= 0, or if you want to set no limit on the maximum number, use the value "unbounded".
    # Default value is 1
    # @!attribute max_occurs
    # @return [Integer, Symbol]
    def self.included(obj)
      obj.property :minOccurs, :integer, default: 1
      obj.property :maxOccurs, :integer, default: 1
    end

    # Compute actual max_occurs accounting parents
    # @return [Integer, Symbol]
    def computed_max_occurs
      @computed_max_occurs ||= if parent.is_a?(MinMaxOccurs)
                                 Math.max(max_occurs, parent.computed_max_occurs)
                               else
                                 max_occurs
                               end
    end

    # Compute actual min_occurs accounting parents
    # @return [Integer]
    def computed_min_occurs
      @computed_min_occurs ||= if parent.is_a?(Choice)
                                 0
                               elsif parent.is_a?(MinMaxOccurs)
                                 Math.min(min_occurs, parent.computed_min_occurs)
                               else
                                 min_occurs
                               end
    end
  end
end