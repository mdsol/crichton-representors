
module Representors
  class SerializerBase
    OPERATION = :serialization

    # The kind of operation we do with the format in here. Used by Serializer to tell the difference
    # between deserializers and serializers
    def self.applied_to
      OPERATION
    end
    
    def initialize(representor, options = {})
      @serialization = serialize(representor)
    end

    def to_media_type(options={})
      @serialization.(options)
    end

  end
end