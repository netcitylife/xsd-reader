module XsdReader
  # The element element defines an element.
  # Parent elements: schema, choice, all, sequence, group
  # https://www.w3schools.com/xml/el_element.asp
  class Element < BaseObject
    include Shared
    include MinMaxOccurs
    include Referenced

    def elements(opts = {})
      return super if opts[:direct] == true
      all_elements
    end

    # Get all attributes available on element
    # @return [Array<Attribute>]
    def attributes
      @attributes ||= complex_type&.attributes || []
    end

    def complex_type
      @_element_complex_type ||= super || linked_complex_type
    end

    # Determine if element is required
    # TODO: consider parent node group/sequence/choice/all min/max occurs
    # @return [Boolean]
    def required?
      min_occurs > 0 && !choice?
    end

    # Determine if element is optional
    # @return [Boolean]
    def optional?
      !required?
    end

    # Determine if element may occur multiple times
    # TODO: consider parent node group/sequence/choice/all min/max occurs
    # @return [Boolean]
    def multiple_allowed?
      max_occurs == :unbounded || max_occurs > 1
    end

    # Determine if element is inside choice
    def choice?
      obj = self
      loop do
        parent = obj.parent
        return true if p.is_a?(Choice)
        break if p.is_a?(ComplexType) || p.is_a?(Schema)
        obj = parent
      end
      false
    end

    # Optional. Specifies a fixed value for the element (can only be used if the element's content is a simple type or text only)
    # @return [String, nil]
    def fixed
      node['fixed']
    end

    def family_tree(stack = [])
      logger.warn('Usage of the family tree function is not recommended as it can take very long to execute and is very memory intensive')
      return @_cached_family_tree if @_cached_family_tree

      if stack.include?(name) # avoid endless recursive loop
        # logger.debug "Element#family_tree aborting endless recursive loop at element with name: #{name} and element stack: #{stack.inspect}"
        return nil
      end

      return "type:#{type_name}" if elements.length == 0

      result = elements.inject({}) do |tree, element|
        tree.merge element.name => element.family_tree(stack + [name])
      end

      @_cached_family_tree = result if stack == [] # only cache if this was the first one called (otherwise there will be way too many caches)
      result
    end
  end
end
