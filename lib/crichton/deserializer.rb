module Crichton

  # Error to raise when the format we are trying to de/serialize is not known by Crichton
  class UnknownFormatError < StandardError
  end

  # This is a convenience class, it can be used as main entry point to this library.
  # The only puporse is to find the correct deserializer.
  class Deserializer
    # Following the factory pattern, this class will just have a create method.
    # Defined in the class itself.
    class << self
      def create(format, document)
        serializer = serializers_mapping(format)
        if serializer
          return serializer.new(document)
        else
          raise UnknownFormatError, "Crichton can not deserialize #{format}"
        end
      end

      private
      # If a client send directly a Content-Type it may have encodings or other things so we want
      # to be more flexible
      def serializers_mapping(format)
        case format
        #A Hale document is a valid Hal document, use hal deserializer till hale's is ready.
        when /application\/vnd.hale\+json/
          Crichton::HalDeserializer
        when /application\/hal\+json/
          Crichton::HalDeserializer
        #It should read all properties nicely
        when /application\/json/
          Crichton::HalDeserializer
        end
      end

    end
  end

end