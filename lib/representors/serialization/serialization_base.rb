module Representors
  class SerializationBase
    attr_reader :target

    def initialize(target)
      @target = target
      @serialization = setup(target)
    end
    
    def self.media_symbols
      @media_symbols ||= Set.new
    end

    def self.media_types
      @media_types ||= Set.new
    end
    
    private
    def self.media_symbol(*symbol)
      @media_symbols = media_symbols | symbol
    end
    
    def self.media_type(*media)
      @media_types = media_types | media
    end
    
    def setup(target)
      target
    end
    
  end
end
