require 'representors/serialization/hal_deserializer'

module Representors
  class HaleDeserializer < HalDeserializer
    media_symbol :hale
    media_type 'application/vnd.hale+json'

    META_KEY = '_meta'.freeze
    REF_KEY = '_ref'.freeze
    DATA_KEY = 'data'.freeze
    RESERVED_KEYS = HalDeserializer::RESERVED_KEYS +  [META_KEY, REF_KEY]
    RESERVED_FIELD_VALUES = Field::SIMPLE_METHODS + [Field::NAME_KEY, Field::SCOPE_KEY, Field::OPTIONS_KEY, Field::VALIDATORS_KEY, Field::DESCRIPTORS_KEY]

    #TODO Make this not terrible (refactor hal deserializer to inherit from hale deserializer)
    # move all logic here
    def builder_add_from_deserialized(builder, media)
      media = dereference_meta_media(media)
      super    
    end

    def deserialize_links(builder, media)
      links = media[LINKS_KEY] || {}
      links.each do |link_rel, link_values|
        link_values = [link_values] unless link_values.is_a?(Array)
        ensure_valid_links!(link_rel, link_values)
        link_values = parse_validators(link_values)
        link_values = parse_options(link_values)
        builder = builder.add_transition_array(link_rel, link_values)
      end

      builder
    end

    private

    def ensure_valid_links!(link_rel, link_values_array)
      raise(DeserializationError, 'CURIE support not implemented for HAL') if link_rel.eql?(CURIE_KEY)

      if link_values_array.map { |link| link[HREF] }.any?(&:nil?)
        raise DeserializationError, 'All links must contain the href attribute'
      end
    end

    def deep_find_and_transform!(obj, target_key, &blk)
      if obj.respond_to?(:key) && obj.key?(target_key)
        yield obj, target_key
      elsif [Array, Hash].include?(obj.class)
        obj.each { |*el| deep_find_and_transform!(el.last, target_key, &blk) }
      end
    end

    def dereference_meta_media(media)
      media = media.dup
      # Remove _meta from media to prevent serialization as property
      meta_info = media.delete(META_KEY)
      deep_find_and_transform!(media, REF_KEY) do |media, ref_key|
        media.delete(ref_key).each { |ref| media[ref] = meta_info[ref] }
      end
      media
    end

    def parse_options(media)
      media = media.dup

      deep_find_and_transform!(media, 'options') do |media, opt_key|
        if !media[opt_key].is_a?(Hash) && media[opt_key].first.is_a?(Hash)
          new_options = media[opt_key].reduce({}) do |memo, hash|
            memo.merge!(hash)
          end
          media[opt_key] = { 'hash' => new_options }
        elsif !media[opt_key].is_a?(Hash)
          media['options'] = { 'list' => media[opt_key].dup }
        end
      end

      media
    end

    def parse_validators(media)
      media = media.dup

      deep_find_and_transform!(media, 'data') do |media, data_key|
        media[data_key].each do |field_key, field_value|
          arr = []
          field_value.each do |k,v|
            arr << {k => media[data_key][field_key].delete(k)} unless RESERVED_FIELD_VALUES.include?(k.to_sym)
          end
          media[data_key][field_key][Field::VALIDATORS_KEY] = arr unless arr.empty?
        end
      end

      media
    end

  end

end
