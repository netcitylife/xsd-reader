require 'logger'

module XsdReader
  module Shared

    def schema_namespace_prefix
      @schema_namespace_prefix ||= [(self.node.namespaces || {}).detect { |ns| ns[1] =~ /XMLSchema/ }.first.split(':')[1], nil].uniq.join(':')
    end

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
    def name
      name_local || name_referenced
    end

    def name_local
      node.attributes['name'] ? node.attributes['name'].value : nil
    end

    def name_referenced
      referenced_element&.name
    end

    def ref
      node.attributes['ref'] ? node.attributes['ref'].value.split(':').last : nil
    end

    def referenced_element
      ref && schema ? schema.elements.find { |el| el.name == ref } : nil
    end

    def type
      node.attributes['type']&.value || referenced_element&.type
    end

    def type_name
      type ? type.split(':').last : nil
    end

    def type_namespace
      type ? type.split(':').first : nil
    end

    # extension and restriction base type
    def base
      node.attributes['base']&.value
    end

    def base_name
      base ? base.split(':').last : nil
    end

    def base_namespace
      base ? base.split(':').first : nil
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

    # TODO: хранить соответствие ноды и объекта и возвращать уже созданные объекты при повторном запросе
    def node_to_object(node)
      fullname = [node.namespace ? node.namespace.prefix : nil, node.name].reject { |str| str.nil? || str == '' }.join(':')
      klass    = class_for(fullname)
      klass.nil? ? nil : klass.new(options.merge(node: node, schema: schema))
    end

    #
    # Child objects
    #

    def prepend_namespace name
      name =~ /^#{schema_namespace_prefix}/ ? name : "#{schema_namespace_prefix}#{name}"
    end

    def mappable_children(xml_name)
      node.xpath("./#{prepend_namespace(xml_name)}").to_a
    end

    def map_children(xml_name)
      # puts "Map Children with #{xml_name} for #{self.class}"
      mappable_children(xml_name).map { |current_node| node_to_object(current_node) }
    end

    def direct_elements
      @direct_elements ||= map_children("element")
    end

    def elements
      direct_elements
    end

    def ordered_elements
      # loop over each interpretable child xml node, and if we can convert a child node
      # to an XsdReader object, let it give its compilation of all_elements
      nodes.map { |node| node_to_object(node) }.compact.map do |obj|
        obj.is_a?(Element) ? obj : obj.ordered_elements
      end.flatten
    end

    def all_elements
      @all_elements ||= (ordered_elements +
        (linked_complex_type ? linked_complex_type.all_elements : []) +
        (referenced_element ? referenced_element.all_elements : [])).uniq
    end

    def child_elements?
      elements.length > 0
    end

    def attributes
      @attributes ||= map_children("attribute") #+
      #(referenced_element ? referenced_element.attributes : [])
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
      complex_types.first || linked_complex_type || referenced_element&.complex_type
    end

    def linked_complex_type
      @linked_complex_type ||= object_by_name('complexType', type) if type
    end

    def simple_contents
      @simple_contents ||= map_children("simpleContent")
    end

    def simple_content
      simple_contents.first
    end

    def complex_contents
      @complex_contents ||= map_children("complexContent")
    end

    def complex_content
      complex_contents.first
    end

    def extensions
      @extensions ||= map_children("extension")
    end

    def extension
      extensions.first
    end

    def simple_types
      @simple_types ||= map_children("simpleType")
    end

    def simple_type
      simple_types.first || linked_simple_type || referenced_element&.simple_type
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

    # def object_by_name(xml_name, name)
    #   # TODO: add namespace hint, otherwise may get errors in imported schemas
    #   # find in local schema, then look in imported schemas
    #   nod = node.xpath("//#{xml_name}[@name=\"#{name}\"]").first
    #   return node_to_object(nod) if nod
    #
    #   # try to find in any of the importers
    #   self.schema.imports.each do |import|
    #     obj = import.reader.schema.object_by_name(xml_name, name)
    #     return obj if obj
    #   end
    #
    #   nil
    # end

    # @param [String] node_name
    # @param [String] name
    # @return [BaseObject, nil]
    def object_by_name(node_name, name)
      node_name = prepend_namespace(node_name)

      # get search schema
      if name.include?(':')
        prefix, local_name = name.split(':')
        search_schema = schema_for_namespace(prefix)
        return nil unless search_schema
      else
        local_name = name
        search_schema = schema
      end

      prefix = schema_namespace_prefix[0..-2]
      namespace = node.namespaces["xmlns#{prefix == '' ? '' : ":#{prefix}"}"]

      nod = search_schema.node.xpath("//#{node_name}[@name=\"#{local_name}\"]", { prefix => namespace }).first
      nod ? node_to_object(nod) : nil
    end

    def schema_for_namespace(ns)
      logger.debug "Shared#schema_for_namespace with namespace: #{ns}"
      return schema if schema.targets_namespace?(ns)

      if import = schema.import_by_namespace(ns)
        logger.debug "Shared#schema_for_namespace found import schema"
        return import.reader.schema
      end

      logger.debug "Shared#schema_for_namespace no result"
      nil
    end
  end
end
