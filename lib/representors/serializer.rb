require 'representors/has_format_knowledge'
require 'representors/serializers/serializer_base'
require 'representors/serializers/hal'
require 'representors/serializers/hale'

module Representors
  class SerializerFactory

    def self.build(representor, format, options={})
      serializer = serializers_mapping(format)
      if serializer
        serializer.new(representor, options)
      else
        raise UnknownFormatError, "Representors can not serialize #{format}"
      end
    end

    def self.known_serializers
      HasFormatKnowledge.all_classes_with_format_knowledge.select do |serializer|
        serializer.applied_to == Serializer::OPERATION
      end
    end
    
    def self.symbol_mapping
      known_serializers.map do |serializer| 
        serializer.symbol_formats.map do |format| 
          {format => serializer}
        end.reduce(:merge)
      end.reduce(:merge)
    end
    
    def self.mime_mapping
      known_serializers.map do |serializer| 
        serializer.iana_formats.map do |format| 
          {format => serializer.symbol_formats[0]}
        end.reduce(:merge)
      end.reduce(:merge)
    end
    
    private
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


# *** known_serializer  ***
#  > 'hash of serializers for making config '
# 
# mime_types = {
#  'application/hal+json' => :hal
#  }
#  
# mime_symbols = {
#   hal: ->(x) Representor::Serializer::Hal(x)
#   }
# 
# serializer = mime_symbols[mime_types[mime]].(object)

