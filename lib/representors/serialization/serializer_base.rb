require 'representors/serialization/serialization_base'
require 'representors/serialization/serializer_factory'

module Representors
  class SerializerBase < SerializationBase
    def self.inherited(subclass)
      SerializerFactory.register_serializers(subclass)
    end
    
    def to_media_type(options = {})
      apply_serialization(options)
    end
  end
end
