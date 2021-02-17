module XsdReader
  module Validator

    # Отвалидировать XML пакеты против XSD
    # @param [String] xml
    def validate_xml(xml)
      document = Nokogiri::XML(xml)

      if !imported_xsd.empty?
        # imports are explicitly provided - put all files in one tmpdir and update import paths appropriately
        xml_schema = nil
        Dir.mktmpdir('XsdReader', tmp_dir) do |dir|
          # create primary xsd file
          file = SecureRandom.urlsafe_base64 + '.xsd'

          # create imported xsd files
          recursive_import_xsd(self, file) do |f, data|
            File.write("#{dir}/#{f}", data)
          end

          # read schema from tmp file descriptor
          xml_schema = Nokogiri::XML::Schema(File.open("#{dir}/#{file}"), Nokogiri::XML::ParseOptions.new.nononet)
        end
      else
        xml_schema = Nokogiri::XML::Schema(self.xsd, Nokogiri::XML::ParseOptions.new.nononet)
      end

      xml_schema.validate(document).map(&:message)
    end

    # Отвалидировать XSD на соответствие стандарту XMLSchema 1.0
    # @return [Array<String>]
    def validate
      reader = XML.new(Pathname.new("#{__dir__}/../xml-schema-1.0.xsd"), imported_xsd: {
        'http://www.w3.org/2001/xml.xsd' => Pathname.new("#{__dir__}/../xml-1.0.xsd")
      })
      reader.validate_xml(xml)
    end

    private

    # Сформировать имена файлов и содержимое XSD схем для корректной валидации
    # @param [XML] reader
    # @param [String] file
    def recursive_import_xsd(reader, file, &block)
      data = reader.xml

      reader.imports.each do |import|
        name = SecureRandom.urlsafe_base64 + '.xsd'
        data = data.sub("schemaLocation=\"#{import.schema_location}\"", "schemaLocation=\"#{name}\"")
        recursive_import_xsd(import.imported_reader, name, &block)
      end

      block.call(file, data)
    end
  end
end