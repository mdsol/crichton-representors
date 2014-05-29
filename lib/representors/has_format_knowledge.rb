module Representors

  module HasFormatKnowledge

    def self.included(base_class)
      base_class.send :extend, ClassMethods
      @@deserializers ||= []
      @@deserializers.push(base_class)
    end

    def self.all_classes_with_format_knowledge
      @@deserializers
    end

    module ClassMethods

      def symbol_formats
        @symbol_formats || []
      end

      def iana_formats
        @iana_formats || []
      end

      private
      def symbol_format(symbol)
        @symbol_formats ||= []
        @symbol_formats.push(symbol)
      end

      def iana_format(iana_format)
        @iana_formats ||= []
        @iana_formats.push(iana_format)
      end
    end
  end

end
