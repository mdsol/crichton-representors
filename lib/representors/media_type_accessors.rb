module Representors
  module MediaTypeAccessors
    def media_symbols
      @media_symbols || []
    end

    def media_types
      @media_types || []
    end

    private
    def media_symbol(symbol)
      @media_symbols ||= []
      @media_symbols.push(symbol)
    end

    def media_type(media_type)
      @media_types ||= []
      @media_types.push(media_type)
    end
  end
end
