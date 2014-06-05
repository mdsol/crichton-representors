require 'representors/serialization/deserializer_factory'
require 'representors/media_type_accessors'

module Representors
  class DeserializerBase
    extend MediaTypeAccessors
    
    attr_reader :document #returns the original document parsed
    
    def self.inherited(subclass)
      DeserializerFactory.register_deserializers(subclass)
    end
  end
end
