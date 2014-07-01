require 'representors/serialization/hal_deserializer'

module Representors
  class HaleDeserializer < HalDeserializer
    media_symbol :hale
    media_type 'application/vnd.hale+json'

    META_KEY = '_meta'.freeze
    RESERVED_KEYS = [LINKS_KEY, META_KEY, EMBEDDED_KEY]


    private

    # Very complex but this will be called by the setup_serialization(media) in HalDeserializer
    # TODO: refactor
    def builder_add_from_deserialized!(builder, data_as_a_hash)
      deserialize_properties!(builder, data_as_a_hash)

      deserialize_links!(builder, data_as_a_hash)
      deserialize_embedded!(builder, data_as_a_hash)
    end

  end
end
