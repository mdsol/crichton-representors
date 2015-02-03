require 'representors/serialization/serialization_base'
require 'representors/serialization/serializer_factory'

module Representors
  class SerializerBase < SerializationBase

    def initialize(target)
      @target = target.empty? ? Representor.new({}) : target
    end

    def self.inherited(subclass)
      SerializerFactory.register_serializers(subclass)
    end

    def to_hash(options = {})
      raise "Abstract method #to_hash not implemented in #{self.class.to_s} serializer class."
    end

  end
end
