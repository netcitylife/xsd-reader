require 'builder'

module XsdReader
  module Generator

    # Generate XML from provided data
    # @param [Hash] data
    # @param [String, Array<String>] element
    # @param [Builder::XmlMarkup] builder
    # @return [Builder::XmlMarkup]
    def generate(data, element = nil, builder = nil)
      # find root element
      root = find_root_element(element)

      # create builder
      builder = builder || default_builder

      # build element tree
      @namespace_index = 0
      build_element(builder, root, data)

      builder
    end

    private

    # Build element tree
    # @param [Builder::XmlMarkup] xml
    # @param [Element] element
    # @param [Hash] data
    # @param [Hash] namespaces
    def build_element(xml, element, data, namespaces = {})

      # get item data
      data = data[element.name]
      raise Error, "Element #{element.name} is required, but no data in provided for it" if element.required? && data.nil?
      return unless data

      # handle repeated items
      if element.multiple_allowed?
        raise Error, "Element is allowed to occur multiple times, but non-array is provided" unless data.is_a?(Array)
      else
        raise Error, "Element is not allowed to occur multiple times, but an array is provided" if data.is_a?(Array)
        data = [data]
      end

      # iterate through each item
      data.each do |item|

        # prepare attributes
        attributes = element.all_attributes.map do |attribute|
          value = item["@#{attribute.name}"]
          value ? [attribute.name, value] : nil
        end.compact.to_h

        # generate element
        if element.complex?
          all_elements = element.all_elements

          # get namespaces for current element and it's children
          prefix = nil
          [*all_elements, element].each do |elem|
            namespace = elem.schema.target_namespace
            unless (prefix = namespaces.key(namespace))
              prefix             = "tns#{@namespace_index += 1}"
              namespaces[prefix] = attributes["xmlns:#{prefix}"] = namespace
            end
          end

          xml.tag!("#{prefix}:#{element.name}", attributes) do
            all_elements.each do |elem|
              build_element(xml, elem, item, namespaces.dup)
            end
          end
        else
          prefix = namespaces.key(element.schema.target_namespace) || element.schema.target_namespace_prefix
          xml.tag!("#{prefix}:#{element.name}", attributes, (item.is_a?(Hash) ? item['#text'] : item))
        end
      end
    end

    # Find root element with provided lookup
    # @param [String, Array<String>, nil] lookup
    def find_root_element(lookup)
      if lookup
        element = schema[*lookup]
        raise Error, "Cant find start element #{lookup}" unless element.is_a?(Element)
        element
      else
        raise Error, "XSD contains more that one root element. Please, specify starting element" if elements.size > 1
        elements.first
      end
    end

    def default_builder
      xml = Builder::XmlMarkup.new
      xml.instruct!
      xml
    end
  end
end