module XsdReader
  module Validator

    # Validate XML against XSD
    # @param [String, Pathname, Nokogiri::XML::Document] xml
    def validate_xml(xml)
      # validate input
      raise ValidationError unless xml.is_a?(Nokogiri::XML::Document) || xml.is_a?(Pathname) || xml.is_a?(String)

      begin
        document = xml.is_a?(Nokogiri::XML::Document) ? xml : Nokogiri::XML(xml)
      rescue Nokogiri::XML::SyntaxError => e
        raise ValidationError, e
      end

      errors = schema_validator.validate(document)
      raise ValidationError, errors.map(&:message).join('; ') if errors.any?
    end

    # Validate XSD against another XSD (by default uses XMLSchema 1.0)
    def validate
      begin
        schema_validator
      rescue Nokogiri::XML::SyntaxError => e
        # TODO: display import map name for imported_xsd
        message = e.message + (e.file ? " in file '#{File.basename(e.file)}'" : '')
        raise ValidationError, message
      end
    end

    private

    # Get Nokogiri::XML::Schema object to validate against
    # @return [Nokogiri::XML::Schema]
    def schema_validator
      return @schema_validator if @schema_validator

      if !imported_xsd.empty?
        # imports are explicitly provided - put all files in one tmpdir and update import paths appropriately
        # TODO: save file/path map to display in errors
        Dir.mktmpdir('XsdReader', tmp_dir) do |dir|
          # create primary xsd file
          file = SecureRandom.urlsafe_base64 + '.xsd'

          # create imported xsd files
          recursive_import_xsd(self, file) do |f, data|
            File.write("#{dir}/#{f}", data)
          end

          # read schema from tmp file descriptor
          @schema_validator = Nokogiri::XML::Schema(File.open("#{dir}/#{file}"), Nokogiri::XML::ParseOptions.new.nononet)
        end
      else
        @schema_validator = Nokogiri::XML::Schema(self.xsd, Nokogiri::XML::ParseOptions.new.nononet)
      end

      @schema_validator
    end

    # Сформировать имена файлов и содержимое XSD схем для корректной валидации
    # @param [XML] reader
    # @param [String] file
    def recursive_import_xsd(reader, file, &block)
      data = reader.xml

      # TODO: handle recursion
      reader.imports.each do |import|
        name = SecureRandom.urlsafe_base64 + '.xsd'
        data = data.sub("schemaLocation=\"#{import.schema_location}\"", "schemaLocation=\"#{name}\"")
        recursive_import_xsd(import.imported_reader, name, &block)
      end

      block.call(file, data)
    end
  end
end