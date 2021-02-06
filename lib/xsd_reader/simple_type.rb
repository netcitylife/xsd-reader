module XsdReader
  class SimpleType
    include Shared

    def restriction
      @restriction ||= map_children('restriction').first
    end
  end
end