module Representors
  class SerializationBase
    attr_reader :target

    def initialize(target)
      @target = target
      @serialization = setup_serialization(target)
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
    
    def apply_serialization(options)
      @serialization.call(options)
    end
    
    def setup_serialization(target)
      ->() { raise NotImplementedError }
    end
    
  end
end
