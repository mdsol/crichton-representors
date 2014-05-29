
module Representors
  class SerializerBase
    OPERATION = :serialization

    def self.applied_to
      OPERATION
    end
  end
end