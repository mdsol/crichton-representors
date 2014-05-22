require 'representors/deserializers/deserialization_error'
require 'representors/deserializers/format_deserializer'
require 'representors/deserializers/hal_deserializer'
require 'representors/deserializers/hale_deserializer'
require 'representors/deserializers/unknown_format_error'

module Representors

  # This is a convenience class, it can be used as main entry point to this library.
  # The only purpose is to build the correct deserializer.
  class Deserializer
    def self.build(format, document)
      serializer = serializers_mapping(format)
      if serializer
        serializer.new(document)
      else
        raise UnknownFormatError, "Crichton can not deserialize #{format}"
      end
    end

    private
    # If a client send directly a Content-Type it may have encodings or other things so we want
    # to be more flexible
    def self.serializers_mapping(format)
      if format.is_a?(Symbol)
        Representors::FormatDeserializer.all_deserializers.find do |deserializer|
          deserializer.symbol_formats.include?(format)
        end
      else
        Representors::FormatDeserializer.all_deserializers.find do |deserializer|
          # because they may send us directly a content-type that may have more than just a format
          deserializer.iana_formats.any?{|deserializer_format| format.include?(deserializer_format) }
        end
      end
    end
  end

end
