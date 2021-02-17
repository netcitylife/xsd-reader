module XsdReader

  class Error < StandardError
  end

  class ValidationError < Error
    attr_reader :errors

    def initialize(msg, errors)
      @errors = errors
      super(msg)
    end
  end

  class ImportError < Error

  end
end