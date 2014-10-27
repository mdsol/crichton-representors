require 'representors/serialization/hal_deserializer'

module Representors
  class HaleDeserializer < HalDeserializer
    media_symbol :hale
    media_type 'application/vnd.hale+json'

    META_KEY = '_meta'.freeze
    REF_KEY = '_ref'.freeze
    RESERVED_KEYS = HalDeserializer::RESERVED_KEYS +  [META_KEY, REF_KEY]

    private

    def builder_add_from_deserialized(builder, media)
      media = dereference_meta_media(media)
      super    
    end

    def dereference_meta_media(media)
      media = media.dup
      meta_info = media.delete(META_KEY) # Remove _meta from media to prevent serialization as property
      nested_find_and_replace!(media, meta_info, REF_KEY)
      media
    end

    def nested_find_and_replace!(obj, metas, target_key)
      if obj.respond_to?(:key?) && obj.key?(target_key)
        obj.delete(target_key).each { |ref| obj[ref] = metas[ref] }
      elsif [Array, Hash].include?(obj.class)
        obj.each { |*el| nested_find_and_replace!(el.last, metas, target_key) }
      end
    end
  end
end
