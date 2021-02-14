require 'rest-client'

module XsdReader
  # The import element is used to add multiple schemas with different target namespace to a document.
  # Parent elements: schema
  # https://www.w3schools.com/xml/el_import.asp
  class Import < BaseObject

    # Optional. Specifies the URI of the namespace to import
    # @!attribute namespace
    # @return [String, nil]
    property :namespace, :string

    # Optional. Specifies the URI to the schema for the imported namespace
    # @!attribute schema_location
    # @return [String, nil]
    property :schemaLocation, :string

    # Get imported reader
    # @return [XsdReader::XML]
    def imported_reader
      return @imported_reader if @imported_reader
      if download_path
        File.write(download_path, download) unless File.file?(download_path)
        return @imported_reader = XsdReader::XML.new(:xsd_file => download_path, logger: reader.logger)
      end

      xml = if options[:xsd_imported_xml] && options[:xsd_imported_xml][schema_location]
              options[:xsd_imported_xml][schema_location]
            else
              download
            end
      @imported_reader = XsdReader::XML.new(xsd_xml: xml, xsd_imported_xml: options[:xsd_imported_xml], logger: reader.logger)
    end

    def uri
      if namespace =~ /\.xsd$/
        namespace
      elsif schema_location =~ /^https?:/
        schema_location
      else
        namespace.gsub(/#{File.basename(schema_location, '.*')}$/, '').to_s + schema_location
      end
    end

    def download
      @download ||= download_uri(uri)
    end

    def download_path
      # we need the parent XSD's path
      return nil if options[:xsd_file].nil?
      parent_path = File.dirname(options[:xsd_file])
      File.join(parent_path, File.basename(schema_location))
    end

    def local_xml
      File.file?(download_path) ? File.read(download_path) : download
    end

    private

    def download_uri(uri)
      reader.logger.debug(XsdReader) {"Downloading import schema for namespace '#{namespace}' from '#{uri}'"}
      response = RestClient.get uri
      response.body
    end
  end
end