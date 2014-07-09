require 'representors/serialization/serialization_base'
require 'representors/serialization/serializer_factory'

module Representors
  class SerializerBase < SerializationBase
    def self.inherited(subclass)
      SerializerFactory.register_serializers(subclass)
    end

    def to_representing_hash(options = {})
      raise "Abstract method #to_representing_hash not implemented in #{self.class.to_s} serializer class."
    end

  end
end
