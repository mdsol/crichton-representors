# General error when there is a problem with any deserialization.
# TODO Move to single error file
module Representors
  class DeserializationError < StandardError
  end
end
