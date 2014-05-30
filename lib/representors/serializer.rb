require 'representors/has_format_knowledge'
require 'representors/serializers/serializer_base'
require 'representors/serializers/hal'
require 'representors/serializers/hale'

module Representors
  module Serializer

    def self.build(representor, format, options={})
      serializer = serializers_mapping(format)
      if serializer
        serializer.new(representor, options)
      else
        raise UnknownFormatError, "Representors can not serialize #{format}"
      end
    end

    private
    # If a client send directly a Content-Type it may have encodings or other things so we want
    # to be more flexible
    def self.serializers_mapping(format)
      serializers = HasFormatKnowledge.all_classes_with_format_knowledge.select do |serializer|
        serializer.applied_to == SerializerBase::OPERATION
      end
      if format.is_a?(Symbol)
        serializers.find do |serializer|
          serializer.symbol_formats.include?(format)
        end
      else
        serializers.find do |serializer|
          # because they may send us directly a content-type that may have more than just a format
          serializer.iana_formats.any?{|format| format.include?(format) }
        end
      end
    end

  end
end
