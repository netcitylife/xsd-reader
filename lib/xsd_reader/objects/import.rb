require 'rest-client'

module XsdReader
  # The import element is used to add multiple schemas with different target namespace to a document.
  # Parent elements: schema
  # https://www.w3schools.com/xml/el_import.asp
  class Import < BaseObject
    include Shared

    # Optional. Specifies the URI of the namespace to import
    # @return [String]
    def namespace
      node['namespace']
    end

    # Optional. Specifies the URI to the schema for the imported namespace
    # @return [String]
    def schema_location
      node['schemaLocation']
    end

    # Get reader for import
    # @return [XsdReader::XML]
    def reader
      return @reader || options[:reader] if @reader || options[:reader]
      if download_path
        File.write(download_path, download) unless File.file?(download_path)
        return @reader = XsdReader::XML.new(:xsd_file => download_path, logger: logger)
      end

      xml = if options[:xsd_imported_xml] && options[:xsd_imported_xml][schema_location]
              options[:xsd_imported_xml][schema_location]
            else
              download
            end
      @reader = XsdReader::XML.new(xsd_xml: xml, xsd_imported_xml: options[:xsd_imported_xml], logger: logger)
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
      @download ||= download_uri(self.uri)
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
      logger.debug("Downloading import schema for namespace '#{namespace}' from '#{uri}'")
      response = RestClient.get uri
      response.body
    end
  end
end