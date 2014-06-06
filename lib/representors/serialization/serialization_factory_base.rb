require 'representors/errors'

module Representors
  module Serialization
    ##
    # Base class for factories that manages the registration of serialization classes and the common factory interface.
    class SerializationFactoryBase
      def self.build(media_type, object)
        klass = serialization_class(media_type)
        if klass
          klass.new(object)
        else
          raise UnknownMediaTypeError, "Unknown media-type: #{media_type}."
        end
      end
  
      def self.media_symbol_mapping
        @media_symbol_mapping ||= registered_serialization_classes.map do |serialization_class|
          serialization_class.media_symbols.map { |media_symbol| { media_symbol => serialization_class } }.reduce(:merge)
        end.reduce(:merge)
      end
  
      def self.media_type_mapping
        @media_type_mapping ||= registered_serialization_classes.map do |serializer|
          serializer.media_types.map { |media_type| { media_type => serializer.media_symbols.first } }.reduce(:merge)
        end.reduce(:merge)
      end
  
  
      private  
      def self.register_serialization_classes(*serializers)
        clear_memoization
        @_registered_serialization_classes ||= []
        @_registered_serialization_classes |= serializers
      end
  
      def self.clear_memoization
        @registered_serialization_classes = nil
        @media_symbol_mapping = nil
        @media_type_mapping = nil
      end
  
      def self.registered_serialization_classes
        @registered_serialization_classes ||= @_registered_serialization_classes.dup.freeze
      end
     
      # If a client send directly a Content-Type it may have encodings or other things so we want
      # to be more flexible
      def self.serialization_class(media_type)
        symbol =  media_type.is_a?(Symbol) ? media_type : media_type_mapping[media_type]
        media_symbol_mapping[symbol]
      end
    end
  end
end 
