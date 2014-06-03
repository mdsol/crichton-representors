require 'representors/deserializers/unknown_format_error'

module Representors
  class SerializationFactoryBase
    def self.build(format, object)
      klass = serializers_mapping(format)
      if klass
        klass.new(object)
      else
        raise UnknownFormatError, "Unknown format: #{format}."
      end
    end

    def self.clear
      @_registered_serializers = []
      @registered_serializers = nil
      #@symbol_mapping = nil
      #@mime_mapping = nil
    end

    def self.symbol_mapping
      @symbol_mapping ||= registered_serialization_classes.map do |serializer|
        serializer.symbol_formats.map do |format|
          {format => serializer}
        end.reduce(:merge)
      end.reduce(:merge)
    end

    def self.mime_mapping
      @mime_mapping ||= registered_serialization_classes.map do |serializer|
        serializer.iana_formats.map do |format|
          {format => serializer.symbol_formats[0]}
        end.reduce(:merge)
      end.reduce(:merge)
    end


    private     
    def self.register_serialization_classes(*serializers)
      @_registered_serializers ||= []
      @registered_serializers = nil
      @_registered_serializers |= serializers
    end

    def self.registered_serialization_classes
      @registered_serializers ||= @_registered_serializers.dup.freeze
    end
   
    # If a client send directly a Content-Type it may have encodings or other things so we want
    # to be more flexible
    def self.serializers_mapping(format)
      if format.is_a?(Symbol)
        symbol_mapping[format]
      else
        symbol_mapping[mime_mapping[format]]
      end
    end
  end
end

