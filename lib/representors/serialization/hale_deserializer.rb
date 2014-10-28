require 'representors/serialization/hal_deserializer'

module Representors
  class HaleDeserializer < HalDeserializer
    media_symbol :hale
    media_type 'application/vnd.hale+json'

    META_KEY = '_meta'.freeze
    REF_KEY = '_ref'.freeze
    RESERVED_KEYS = HalDeserializer::RESERVED_KEYS +  [META_KEY, REF_KEY]

    private

    #TODO Make this not terrible (refactor hal deserializer to inherit from hale deserializer)
    # move all logic here
    def builder_add_from_deserialized(builder, media)
      media = dereference_meta_media(media)
      media = parse_options(media)
      media = parse_validators(media)
      super    
    end

    private

    def dereference_meta_media(media)
      media = media.dup
      # Remove _meta from media to prevent serialization as property
      meta_info = media.delete(META_KEY)
      dereference_meta_media!(media, meta_info)
      media
    end

    def dereference_meta_media!(obj, metas)
      if obj.respond_to?(:key?) && obj.key?(REF_KEY)
        obj.delete(REF_KEY).each { |ref| obj[ref] = metas[ref] }
      elsif [Array, Hash].include?(obj.class)
        obj.each { |*el| dereference_meta_media!(el.last, metas) }
      end
    end

    def parse_options(media)
      media = media.dup
      parse_options!(media)
      media
    end

    def parse_options!(obj)
      if obj.respond_to?(:key?) && obj.key?('options')
          if !obj['options'].is_a?(Hash) && obj['options'].first.is_a?(Hash)
            new_options = obj['options'].reduce({}) do |memo, hash|
              memo.merge!(hash)
            end
            obj['options'] = { 'hash' => new_options }
          elsif !obj['options'].is_a?(Hash)
            obj['options'] = { 'list' => obj['options'].dup }
          end
      elsif [Array, Hash].include?(obj.class)
        obj.each { |*el| parse_options!(el.last) }
      end
    end

    def parse_validators(media)
      media = media.dup
      parse_validators!(media)
      media
    end

    def parse_validators!(obj)
      if obj.respond_to?(:key?) && obj.key?('data')
        obj['data'].each do |field_key, field_value|
          arr = []
          field_value.each do |k,v|
            unless (Field::SIMPLE_METHODS + [Field::NAME_KEY, Field::SCOPE_KEY, Field::OPTIONS_KEY, Field::VALIDATORS_KEY, Field::DESCRIPTORS_KEY]).include?(k.to_sym)
              arr << {k => obj['data'][field_key].delete(k)}
            end
          end
          obj['data'][field_key]['validators'] = arr unless arr.empty?
        end
      elsif [Array, Hash].include?(obj.class)
        obj.each { |*el| parse_validators!(el.last) }
      end
    end

  end
end
