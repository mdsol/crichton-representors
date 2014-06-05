require 'representors/serialization/serializer_factory'
require 'representors/media_type_accessors'

module Representors
  class SerializerBase
    extend MediaTypeAccessors
    
    def self.inherited(subclass)
      SerializerFactory.register_serializers(subclass)
    end
    
    def initialize(representor)
      @serialization = serialize(representor)
    end

    def to_media_type(options = {})
      @serialization.(options)
    end
  end
end
