require 'representors/serialization/serialization_factory_base'

module Representors
  class DeserializerFactory < SerializationFactoryBase
    def self.register_deserializers(*serializers)
      register_serialization_classes(*serializers)
    end

    def self.registered_deserializers
      registered_serialization_classes
    end
  end
end
