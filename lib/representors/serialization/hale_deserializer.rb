require 'representors/serialization/hal_deserializer'

module Representors
  module Serialization
    class HaleDeserializer < HalDeserializer
      media_symbol :hale
      media_type 'application/vnd.hale+json'
    end
  end
end
