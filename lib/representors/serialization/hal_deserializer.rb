
require 'representors/serialization/hale_deserializer'

module Representors 
  ##
  # Deserializes the HAL format as specified in http://stateless.co/hal_specification.html
  # For examples of how this format looks like check the files under spec/fixtures/hal
  # TODO: support Curies http://www.w3.org/TR/2010/NOTE-curie-20101216/
  class HalDeserializer < HaleDeserializer
    media_symbol :hal
    media_type 'application/hal+json', 'application/json'
    
    HAL_LINK_KEYS = %w(href templated type deprecation name profile title hreflang)
    RESERVED_KEYS = [LINKS_KEY, EMBEDDED_KEY]
    
    private
    
    def builder_add_from_deserialized(builder, media)
      builder = deserialize_properties(builder, media)
      builder = deserialize_links(builder, media)
      builder = deserialize_embedded(builder, media)
    end
    
    def deserialize_links(builder, media)
      (media[LINKS_KEY] || {}).each do |link_rel, link_values|
        
        link_values = [link_values] unless link_values.is_a?(Array)
        link_values = link_values.map do |hash| 
          hash.select { |k,_| HAL_LINK_KEYS.include?(k) }
        end
        ensure_valid_links!(link_rel, link_values)
        builder = builder.add_transition_array(link_rel, link_values)
      end
      builder
    end
    
    def deserialize_properties(builder, media)
      media.each do |k,v|
        builder = builder.add_attribute(k, v) unless (self.class::RESERVED_KEYS.include?(k))
      end
      builder
    end
    
  end
end
