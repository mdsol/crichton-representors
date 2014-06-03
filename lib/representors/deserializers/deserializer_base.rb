require 'representors/deserializer_factory'

module Representors
  class DeserializerBase
    extend HasFormatKnowledge
    
    def self.inherited(subclass)
      DeserializerFactory.register_deserializers(subclass)
    end
  end
end
