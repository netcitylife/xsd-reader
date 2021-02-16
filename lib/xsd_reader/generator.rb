require 'builder'

module XsdReader
  module Generator

    # Generate XML from provided data
    # @param [Hash] data
    # @param [String, Array<String>] element
    # @param [Builder::XmlMarkup] builder
    def generate(data, element = nil, builder = nil)
      # find root element
      root = find_root_element(element)

      # create builder
      builder = builder || default_builder

      # build element tree
      build_element(builder, root, data)

      builder.target!
    end

    private

    # Build element tree
    # @param [Builder::XmlMarkup] xml
    # @param [Element] element
    # @param [Hash] data
    def build_element(xml, element, data)

      # handle repeated items
      if !element.multiple_allowed? && data.is_a?(Array)
        raise Error, "Element is not allowed to occur multiple times, but an array is provided"
      end

      # iterate through each item
      (data.is_a?(Array) ? data : [data]).each do |item|
        puts "item: #{item}"
        puts "element: #{element.name}"
        # get item data
        data = item[element.name]
        next unless data

        # prepare attributes
        attributes = element.all_attributes.map do |attribute|
          value = data["@#{attribute.name}"]
          value ? [attribute.name, value] : nil
        end.compact.to_h

        # prepare namespace
        namespace = :tag!

        # generate element
        if element.complex?
          xml.__send__(namespace, element.name.to_sym, attributes) do
            element.all_elements.each do |elem|
              build_element(xml, elem, data)
            end
          end
        else
          xml.__send__(namespace, element.name.to_sym, attributes, (data.is_a?(Hash) ? data['#text'] : data))
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