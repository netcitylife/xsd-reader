module XsdReader
  # The schema element defines the root element of a schema.
  # Parent elements: NONE
  # https://www.w3schools.com/xml/el_schema.asp
  class Schema < BaseObject
    include Shared

    # Optional. A URI reference of the namespace of this schema
    # @return [String]
    def target_namespace
      node['targetNamespace']
    end

    def schema
      self
    end

    def target_namespace_prefix
      return nil unless target_namespace
      namespaces.select { |k, v| v == target_namespace }.keys.first.sub('xmlns:', '')
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

    def import_by_namespace(ns)
      aliases = [ns, namespaces["xmlns:#{(ns || '').gsub(/^xmlns:/, '')}"]].compact
      imports.find { |import| aliases.include?(import.namespace) }
    end
  end
end