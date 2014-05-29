
module Representors

  # Base of all the serializers, small now, see if we make use of this.
  class DeserializerBase

    OPERATION = :deserialization

    # The kind of operation we do with the format in here. Used by Deserializer to tell the difference
    # between deserializers and serializers
    def self.applied_to
      OPERATION
    end
  end
end