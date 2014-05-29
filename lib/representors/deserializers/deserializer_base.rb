
module Representors
  class DeserializerBase

    OPERATION = :deserialization

    def self.applied_to
      OPERATION
    end
  end
end