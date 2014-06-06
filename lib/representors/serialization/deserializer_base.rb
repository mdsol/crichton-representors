require 'representors/serialization/base'
require 'representors/serialization/deserializer_factory'
require 'representors/errors'

module Representors
  module Serialization
    class DeserializerBase < Base
      def self.inherited(subclass)
        DeserializerFactory.register_deserializers(subclass)
      end
      
      private
      def raise_error(message)
        raise DeserializationError, message
      end
    end
  end
end
