require 'nokogiri'

module XsdReader
  class XML
    attr_reader :options

    def initialize(opts = {})
      @options = opts || {}
      raise "#{self.class}.new expects a hash parameter" unless @options.is_a?(Hash)
    end

    def logger
      options[:logger] || default_logger
    end

    def default_logger
      @default_logger ||= Logger.new(STDOUT).tap do |logr|
        logr.level = Logger::WARN
      end
    end

    def xml
      @xsd_xml ||= options[:xsd_xml] || File.read(options[:xsd_file])
    end

    def doc
      @doc ||= Nokogiri.XML(xml)
    end

    def schema_node
      raise Error, 'Document root not found, provided document does not seem to be a valid XSD' unless doc.root
      doc.root.name == 'schema' ? doc.root : nil
    end

    def schema
      @schema ||= Schema.new(self.options.merge(:node => schema_node, :logger => logger))
    end

    # Get element by path
    # @return [XsdReader::Element, nil]
    def [](*args)
      schema[*args]
    end

    def elements
      schema.elements
    end

    def imports
      schema.imports
    end

    def simple_types
      schema.simple_types
    end

    def schema_for_namespace(_ns)
      schema.schema_for_namespace(_ns)
    end
  end

  class Error < StandardError
  end
end
