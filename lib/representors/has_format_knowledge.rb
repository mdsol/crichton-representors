module Representors
  module HasFormatKnowledge
    def symbol_formats
      @symbol_formats || []
    end

    def iana_formats
      @iana_formats || []
    end

    private
    def symbol_format(symbol)
      @symbol_formats ||= []
      @symbol_formats.push(symbol)
    end

    def iana_format(iana_format)
      @iana_formats ||= []
      @iana_formats.push(iana_format)
    end
  end
end
