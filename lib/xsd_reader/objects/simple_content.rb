module XsdReader
  class SimpleContent < BaseObject
    include Shared

    def attributes
      super + (extension ? extension.attributes : [])
    end
  end
end