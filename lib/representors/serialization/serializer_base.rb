require 'representors/serialization/serialization_base'
require 'representors/serialization/serializer_factory'

module Representors
  module Serialization
    class SerializerBase < SerializationBase
      def self.inherited(subclass)
        SerializerFactory.register_serializers(subclass)
      end
      
      def to_media_type(options = {})
        @serialization ||= serialize(target)
        @serialization.call(options)
      end
    end
  end
end
