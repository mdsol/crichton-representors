require 'representors/serialization/hal_serializer'

module Representors
  module Serialization
    class HaleSerializer < HalSerializer
      media_symbol :hale
      media_type 'application/vnd.hale+json'

      # This is public and returning a hash to be able to implement embedded resources
      # serialization
      # TODO: make this private and merge with to_media_type
      # The name is quite misleading,
      def to_representing_hash(options ={})
        base_hash, links, embedded_hales = common_serialization(@target)
        meta = get_data_lists(@target)
        base_hash.merge!(meta).merge!(links).merge!(embedded_hales.(options))
        base_hash
      end


      # This is the main entry of this class. It returns a serialization of the data
      # in a given media type.
      def to_media_type(options = {})
        to_representing_hash(options).to_json
      end

      private

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
        element_data[:options] = options unless options.empty?
        { element.name => element_data }
      end

      def build_links_for_this_media_type(transition)
        link = super(transition) #default Hal serialization
        # below add fields specific for Hale
        data_elements = transition.attributes.reduce({}) do |results, element|
          results.merge( get_data_element(element) )
        end
        link[:data] = data_elements unless data_elements.empty?
        link
      end
    end
  end
end
