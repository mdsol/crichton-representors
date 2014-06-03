module Representors
  module MediaTypeAccessors
    def media_symbols
      @media_symbols ||= Set.new
    end

    def media_types
      @media_types ||= Set.new
    end

    private
    def media_symbol(symbol)
      media_symbols << symbol
    end

    def media_type(media_type)
      media_types << media_type
    end
  end
end
