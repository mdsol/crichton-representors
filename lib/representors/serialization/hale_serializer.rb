require 'representors/serialization/hal_serializer'

module Representors
  module Serialization
    class HaleSerializer < HalSerializer
      media_symbol :hale
      media_type 'application/vnd.hale+json'

      SEMANTIC_TYPES = {
        select: "text", #No way in Crichton to distinguish [Int] and [String]
        search:"text",
        text: "text",
        boolean: "bool", #a Server should accept ?cat&dog or ?cat=cat&dog=dog
        number: "number",
        email: "text",
        tel: "text",
        datetime: "text",
        time: "text",
        date: "text",
        month: "text",
        week: "text",
        object: "object",
        :"datetime-local" => "text"
      }
      # This is public and returning a hash to be able to implement embedded resources
      # serialization
      # TODO: make this private and merge with to_media_type
      # The name is quite misleading,
      def to_hash(options ={})
        base_hash, links, embedded_hales = common_serialization(@target)
        meta = get_data_lists(@target)
        base_hash.merge!(meta).merge!(links).merge!(embedded_hales.(options))
        base_hash
      end


      # This is the main entry of this class. It returns a serialization of the data
      # in a given media type.
      def to_media_type(options = {})
        to_hash(options).to_json
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
        element_data = {} # element.to_hash[element.name]
        element_data.merge!(element.validators.reduce({}) { |results, validator| results.merge( validator.is_a?(Hash) ? validator : {validator => true} )})
        element_data[:type] = render_type(element.field_type,element.type) if element.field_type || element.type
        element_data[:scope] = element.scope unless element.scope == 'attribute'
        element_data[:value] = element.value unless element.value.nil?
        element_data[:multi] = true if element.cardinality == "multiple"
        element_data[:options] = options.to_data unless options.empty?
        element_data[:data] = render_data_elements(element.descriptors) if element.type == 'object'
        { element.name => element_data }
      end

      def render_data_elements(elements)
        elements.reduce({}) do |results, element|
          results.merge( get_data_element(element) )
        end
      end

      def build_links_for_this_media_type(transition)
        link = super(transition) #default Hal serialization
        # below add fields specific for Hale
        data_elements = render_data_elements(transition.descriptors)
        link[:data] = data_elements unless data_elements.empty?
        link[:method] = transition.interface_method unless transition.interface_method == "GET"
        link
      end
      
      def render_type(field_type, type)
        type = type || SEMANTIC_TYPES[field_type.to_sym]
        field_type ? "#{type}:#{field_type}" : "#{type}"
      end
    end
  end
end
