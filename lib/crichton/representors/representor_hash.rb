module Crichton
  module Representors
    # This is the structure shared between the builder and the representor.
    # Encapsulate the name of the keys constants
    # TODO: create documentation with this:
    #  https://gist.github.com/sheavalentine-mdsol/69649d4e1aeee76de21c
    class RepresentorHash < Hash
      SEMANTICS_KEY = :semantics
      TRANSITIONS_KEY = :transitions
      EMBEDDED_KEY = :embedded
      def attributes=(attributes)
        merge!({SEMANTICS_KEY => attributes})
      end
      def transitions=(transitions_array)
        merge!({TRANSITIONS_KEY => transitions_array})
      end

      def embedded=(embedded_array)
        merge!({EMBEDDED_KEY => embedded_array})
      end

      def embedded
        self[EMBEDDED_KEY]
      end

      def attributes
        self[SEMANTICS_KEY]
      end

      def transitions
        self[TRANSITIONS_KEY]
      end
    end

  end
end