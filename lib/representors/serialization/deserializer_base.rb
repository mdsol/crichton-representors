require 'representors/serialization/serialization_base'
require 'representors/serialization/deserializer_factory'

module Representors
  class DeserializerBase < SerializationBase
    def self.inherited(subclass)
      DeserializerFactory.register_deserializers(subclass)
    end
  end
end
