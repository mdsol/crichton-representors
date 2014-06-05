# Error to raise when the format we are trying to de/serialize is not known by this gem

# TODO Move to single error file
module Representors
  class UnknownFormatError < StandardError
  end
end
