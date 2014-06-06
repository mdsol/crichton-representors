require 'representors/serialization/serialization_factory_base'

module Representors
  module Serialization
    class SerializerFactory < SerializationFactoryBase
      def self.register_serializers(*serializers)
        register_serialization_classes(*serializers)
      end
  
      def self.registered_serializers
        registered_serialization_classes
      end
    end
  end
end
