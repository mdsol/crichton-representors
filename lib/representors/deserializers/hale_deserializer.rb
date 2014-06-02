module Representors

  class HaleDeserializer < HalDeserializer

    include HasFormatKnowledge

    symbol_format :hale
    iana_format 'application/vnd.hale+json'
  end

end