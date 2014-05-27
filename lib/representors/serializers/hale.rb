module Representors
  module Serialization
    class HaleSerializer < HalSerializer
      @media_types = ['vnd.hale', 'hale']
      @formats = ['json', 'yaml']      
      
      private
      
      def serialize(representor)
        base_hash = get_semantics(representor)
        embedded_links, embedded_hales = get_embedded_elements(representor)
        links = representor.transitions.map { |link| construct_links(link) }+embedded_links

        links = links != [] ? { '_links' => links.reduce({}, :merge) } : {}
        meta = get_data_lists(representor)
        ->(options) { base_hash.merge(meta).merge(links).merge(embedded_hales.(options)) }
      end
      
      def get_data_lists(representor)
        meta = {}
        representor.datalists.each do |datalist|
          meta[datalist.id] = datalist.as_data
        end
        meta.empty? ? {} : {'_meta' => meta } 
      end
      
      def get_data_element(element)
        options = element.options.datalist? ? { '_ref' => [element.options.id] } : element.options
        element_data = element.to_hash[element.name]
        element_data[:options] = options
        { element.name => element_data }
      end
      
      def construct_links(transition)
        link = if transition.templated?
          { href:  transition.templated_uri, templated: true }
        else
          { href: transition.uri }
        end
        link[:method] = transition.interface_method
        data_elements = transition.attributes.reduce({}) do |results, element|
          results.merge( get_data_element(element) )
        end
        link[:data] = data_elements unless data_elements.empty?
        { transition.rel => link }
      end     
      
    end
  end
end