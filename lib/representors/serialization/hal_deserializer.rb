
require 'representors/serialization/hale_deserializer'

module Representors 
  ##
  # Deserializes the HAL format as specified in http://stateless.co/hal_specification.html
  # For examples of how this format looks like check the files under spec/fixtures/hal
  # TODO: support Curies http://www.w3.org/TR/2010/NOTE-curie-20101216/
  class HalDeserializer < HaleDeserializer
    media_symbol :hal
    media_type 'application/hal+json', 'application/json'
    
    RESERVED_KEYS = HalDeserializer::RESERVED_KEYS -  [META_KEY, REF_KEY]
  end
end
