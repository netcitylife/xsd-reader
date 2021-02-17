module XsdReader

  class Error < StandardError
  end

  class ValidationError < Error
  end

  class ImportError < Error
  end
end