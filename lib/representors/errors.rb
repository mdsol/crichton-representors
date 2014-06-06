module Representors
  # General error when there is a problem with any deserialization.
  class DeserializationError < StandardError; end

  # Error to raise when the media-type we are trying to de/serialize is not known by this gem
  class UnknownMediaTypeError < StandardError; end
end
