require 'representors/deserializers/hal_deserializer'

module Representors
  class HaleDeserializer < HalDeserializer
    symbol_format :hale
    iana_format 'application/vnd.hale+json'
  end
end
