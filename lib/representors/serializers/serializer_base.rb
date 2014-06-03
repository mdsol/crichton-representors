require 'representors/serializer_factory'

module Representors
  class Serializer
    extend HasFormatKnowledge
    
    def self.inherited(subclass)
      SerializerFactory.register_serializers(subclass)
    end
    
    def initialize(representor, options = {})
      @serialization = serialize(representor)
    end

    def to_media_type(options = {})
      @serialization.(options)
    end
  end
end
