require 'representors/serialization/serialization_base'
require 'representors/serialization/deserializer_factory'
require 'representors/errors'

module Representors
  class DeserializerBase < SerializationBase
    def self.inherited(subclass)
      DeserializerFactory.register_deserializers(subclass)
    end
    
    private
    def raise_error(message)
      raise DeserializationError, message
    end
  end
end
