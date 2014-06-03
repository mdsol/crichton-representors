require 'representors/deserializers/unknown_format_error'

module Representors
  class SerializationFactoryBase
    def self.build(media_type, object)
      klass = serialization_class(media_type)
      if klass
        klass.new(object)
      else
        raise UnknownFormatError, "Unknown media-type: #{media_type}."
      end
    end

    def self.symbol_mapping
      @symbol_mapping ||= registered_serialization_classes.map do |serialization_class|
        serialization_class.media_symbols.map do |media_symbol|
          {media_symbol => serialization_class }
        end.reduce(:merge)
      end.reduce(:merge)
    end

    def self.mime_mapping
      @mime_mapping ||= registered_serialization_classes.map do |serializer|
        serializer.media_types.map do |media_type|
          { media_type => serializer.media_symbols.first }
        end.reduce(:merge)
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
      @mime_mapping = nil
      @symbol_mapping = nil
    end

    def self.registered_serialization_classes
      @registered_serialization_classes ||= @_registered_serialization_classes.dup.freeze
    end
   
    # If a client send directly a Content-Type it may have encodings or other things so we want
    # to be more flexible
    def self.serialization_class(media_type)
      symbol =  media_type.is_a?(Symbol) ? media_type : mime_mapping[media_type]
      symbol_mapping[symbol]
    end
  end
end
