require 'representors/deserializer_factory'
require 'representors/media_type_accessors'

module Representors
  class DeserializerBase
    extend MediaTypeAccessors
    
    def self.inherited(subclass)
      DeserializerFactory.register_deserializers(subclass)
    end
  end
end
