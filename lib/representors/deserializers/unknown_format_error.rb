# Error to raise when the format we are trying to de/serialize is not known by this gem
module Representors
  class UnknownFormatError < StandardError
  end
end
