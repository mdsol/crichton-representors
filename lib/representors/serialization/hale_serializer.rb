require 'representors/serialization/hal_serializer'

module Representors
  module Serialization
    class HaleSerializer < HalSerializer
      media_symbol :hale
      media_type 'application/vnd.hale+json'

      private
      def setup_serialization(representor)
        base_hash, links, embedded_hales = common_serialization(representor)
        meta = get_data_lists(representor)
        ->(options) { base_hash.merge(meta).merge(links).merge(embedded_hales.(options)) }
      end

      def get_data_lists(representor)
        meta = {}
        representor.datalists.each do |datalist|
          meta[datalist.id] = datalist.to_data
        end
        meta.empty? ? {} : {'_meta' => meta }
      end

      def get_data_element(element)
        options = element.options.datalist? ? { '_ref' => [element.options.id] } : element.options
        element_data = element.to_hash[element.name]
        element_data[:options] = options
        { element.name => element_data }
      end

      def build_links(transition)
        uri = transition.templated? ? transition.templated_uri : transition.uri
        link = { href:  uri, templated: true }
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
