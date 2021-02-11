require 'logger'

module XsdReader
  module Shared

    def schema_namespace_prefix
      @schema_namespace_prefix ||= [(self.node.namespaces || {}).detect { |ns| ns[1] =~ /XMLSchema/ }.first.split(':')[1], nil].uniq.join(':')
    end

    # Get element by path
    # @return [Element, nil]
    def [](*args)
      # now name is always an array
      names = args.flatten

      result = self

      names.each do |curname|
        next if result.nil?

        if curname.to_s =~ /^@/
          attr_name = curname.to_s.gsub(/^@/, '')
          result    = result.attributes.find { |attr| attr.name == attr_name }
        else
          result = result.elements.find { |child| child.name == curname.to_s }
        end
      end

      result
    end

    #
    # attribute properties
    #

    def type_name
      type ? type.split(':').last : nil
    end

    def type_namespace
      type ? type.split(':').first : nil
    end

    # Return element documentation
    # @return [String]
    def documentation
      documentation_for(node)
    end

    # Return documentation for specified node
    # @param [Nokogiri::Xml::Node] node
    # @return [String]
    def documentation_for(node)
      xs  = schema_namespace_prefix
      doc = node.xpath("./#{xs}annotation/#{xs}documentation/text()").map(&:to_s).map(&:strip).join("\n")
      doc.empty? ? nil : doc
    end

    #
    # Child objects
    #

    def prepend_namespace(name)
      name =~ /^#{schema_namespace_prefix}/ ? name : "#{schema_namespace_prefix}#{name}"
    end

    def elements
      direct_elements
    end

    # Get all direct child elements
    def direct_elements
      @direct_elements ||= map_children("element")
    end

    # Get all nested elements
    def nested_elements
      # loop over each interpretable child xml node, and if we can convert a child node
      # to an XsdReader object, let it give its compilation of all_elements
      nodes.map { |node| node_to_object(node) }.compact.map do |obj|
        obj.is_a?(Element) ? obj : obj.nested_elements
      end.flatten
    end

    # Get all elements, including
    def all_elements
      @all_elements ||= nested_elements + (linked_complex_type&.all_elements || [])
    end

    def child_elements?
      elements.length > 0
    end

    def sequences
      @sequences ||= map_children("sequence")
    end

    def choices
      @choices ||= map_children("choice")
    end

    def complex_types
      @complex_types ||= map_children("complexType")
    end

    def complex_type
      complex_types.first || linked_complex_type || referenced_object&.complex_type
    end

    def linked_complex_type
      @linked_complex_type ||= object_by_name('complexType', type) if type
    end

    def simple_types
      @simple_types ||= map_children("simpleType")
    end

    def simple_type
      simple_types.first || linked_simple_type || referenced_object&.simple_type
    end

    def linked_simple_type
      @linked_simple_type ||= object_by_name('simpleType', type) if type
    end

    #
    # Related objects
    #

    def parent
      if node && node.respond_to?(:parent) && node.parent

        return node_to_object(node.parent)
      end

      nil
    end

    def schema
      return options[:schema] if options[:schema]
      schema_node = node.xpath("//#{schema_namespace_prefix}schema")[0]
      schema_node.nil? ? nil : node_to_object(schema_node)
    end

    def schema_for_namespace(ns)
      return schema if schema.targets_namespace?(ns)

      if import = schema.import_by_namespace(ns)
        return import.reader.schema
      end

      logger.debug "Schema not found for namespace prefix '#{ns}'"
      nil
    end
  end
end
