require 'representors/serialization/serialization_factory_base'

module Representors
  class SerializerFactory < SerializationFactoryBase
    def self.register_serializers(*serializers)
      register_serialization_classes(*serializers)
    end

    def self.registered_serializers
      registered_serialization_classes
    end

    def self.serializer?(serializer_name)
      registered_serializers.any? { |serializer| serializer.media_symbol.include?(serializer_name.to_sym) }
    end
  end
end
