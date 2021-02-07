require 'rest-client'

module XsdReader
  class Import < BaseObject
    include Shared

    def namespace
      node.attributes['namespace']&.value
    end

    def schema_location
      node.attributes['schemaLocation']&.value
    end

    def reader
      return @reader || options[:reader] if @reader || options[:reader]
      if download_path
        File.write(download_path, download) unless File.file?(download_path)
        return @reader = XsdReader::XML.new(:xsd_file => download_path)
      end

      @reader = XsdReader::XML.new(:xsd_xml => download)
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
      logger.info "Downloading import schema from (#{uri})"
      response = RestClient.get uri
      response.body
    end
  end
end