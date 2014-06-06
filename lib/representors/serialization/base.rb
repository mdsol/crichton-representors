module Representors
  module Serialization
    class Base
      attr_reader :target
      
      def self.media_symbols
        @media_symbols ||= Set.new
      end
  
      def self.media_types
        @media_types ||= Set.new
      end
  
      def self.media_symbol(*symbol)
        @media_symbols = media_symbols | symbol
      end
      private_class_method :media_symbol
      
      def self.media_type(*media)
        @media_types = media_types | media
      end
      private_class_method :media_type
      
      def initialize(target)
        @target = target
      end
    end
  end
end
