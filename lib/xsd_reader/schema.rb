module XsdReader
  class Schema
    include Shared

    def schema
      self
    end

    def target_namespace
      node && node.attributes['targetNamespace'] ? node.attributes['targetNamespace'].value : nil
    end

    def namespaces
      self.node ? self.node.namespaces : {}
    end

    def targets_namespace?(ns)
      target_namespace == ns || target_namespace == namespaces["xmlns:#{ns}"]
    end

    def imports
      @imports ||= map_children("import")
    end

    def mappable_children(xml_name)
      result = super
      result += import_mappable_children(xml_name) if xml_name != 'import'
      result.to_a
    end

    def import_mappable_children(xml_name)
      self.imports.map { |import| import.reader.schema.mappable_children(xml_name) }.flatten
    end

    def import_by_namespace(ns)
      aliases = [ns, namespaces["xmlns:#{(ns || '').gsub(/^xmlns\:/, '')}"]].compact
      imports.find { |import| aliases.include?(import.namespace) }
    end
  end
end