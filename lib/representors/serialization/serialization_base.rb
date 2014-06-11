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
    
    # @note setup_serialization _must_ return a lambda, 
    #   this allows delayed evaluation of computation that's dependent on options
    def setup_serialization(target)
      raise NotImplementedError, "Abstract method #setup_serialization must be implemented in #{self.class.name}."
    end
    
  end
end
