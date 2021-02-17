module XsdReader
  module Validator

    # Отвалидировать XML пакеты против XSD
    # @param [String, Pathname] xml
    def validate_xml(xml)
      begin
        document = Nokogiri::XML(xml)
      rescue Nokogiri::XML::SyntaxError => e
        raise ValidationError, e
      end

      errors = schema_validator.validate(document)
      raise ValidationError, errors.map(&:message).join('; ') if errors.any?
    end

    # Validate XSD against another XSD (by default uses XMLSchema 1.0)
    # @return [nil]
    def validate
      begin
        schema_validator
      rescue Nokogiri::XML::SyntaxError => e
        raise ValidationError.new(e.message)
      end
    end

    # def validate(reader = nil)
    #   reader ||= XML.new(Pathname.new("#{__dir__}/../xml-schema-1.0.xsd"))
    #
    #   begin
    #     @validated_schemas = []
    #     validate_xsd(reader)
    #   rescue ValidationError => e
    #     # TODO: identify current xsd some way
    #     raise ValidationError.new("XSD validation failed", e.errors)
    #   rescue ImportError => e
    #     # TODO: identify current xsd some way
    #     raise ValidationError.new("XSD validation failed", e.message)
    #   ensure
    #     @validated_schemas = []
    #   end
    #   nil
    # end

    private

    # Validate current XSD against passed XSD
    # @param [XML]
    # def validate_xsd(reader)
    #   # validate current xsd
    #   reader.validate_xml(xsd)
    #   @validated_schemas.push(schema.target_namespace)
    #
    #   # validate imports
    #   imports.each do |import|
    #     if @validated_schemas.include?(import.namespace)
    #       logger.debug(XsdReader) { "Schema '#{import.namespace}' already validated, skiping" }
    #       next
    #     end
    #     import.imported_reader.validate(reader)
    #   end
    # end

    # Get Nokogiri::XML::Schema object to validate against
    # @return [Nokogiri::XML::Schema]
    def schema_validator
      return @schema_validator if @schema_validator

      if !imported_xsd.empty?
        # imports are explicitly provided - put all files in one tmpdir and update import paths appropriately
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