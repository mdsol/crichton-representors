require 'json'
require 'representors/serialization/deserializer_base'
require 'representors/errors'

module Representors
  ##
  # Deserializes the HAL format as specified in http://stateless.co/hal_specification.html
  # For examples of how this format looks like check the files under spec/fixtures/hal
  # TODO: support Curies http://www.w3.org/TR/2010/NOTE-curie-20101216/
  class HalDeserializer < DeserializerBase
    LINKS_KEY = '_links'.freeze
    EMBEDDED_KEY = '_embedded'.freeze
    CURIE_KEY = 'curies'.freeze
    HREF = 'href'.freeze
    RESERVED_KEYS = [LINKS_KEY, EMBEDDED_KEY]

    media_symbol :hal
    media_type 'application/hal+json', 'application/json'

    # This need to be public to support embedded data
    # TODO: make this private
    def to_representor_hash(_options = {})
      media = @target.is_a?(Hash) ? @target : JSON.parse(@target)
      builder = RepresentorBuilder.new
      builder_add_from_deserialized!(builder, media)
      builder.to_representor_hash
    end

    private

    def builder_add_from_deserialized!(builder, media)
      deserialize_properties!(builder, media)
      deserialize_links!(builder, media)
      deserialize_embedded!(builder, media)
    end

    # Properties are normal JSON keys in the HAL document. Create properties in the resulting object
    def deserialize_properties!(builder, media)
      media.keys.each do |property_name|
        # links and embedded are not properties but keywords of HAL, skipping them.
        unless (RESERVED_KEYS.include?(property_name))
          builder.add_attribute(property_name, media[property_name])
        end
      end
    end

    # links are under '_links' in the original document. Links always have a key (its name) but
    # the value can be a hash with its properties or an array with several links.
    def deserialize_links!(builder, media)
      links = media[LINKS_KEY] || {}
      links.each do |link_rel, link_values|
        raise(DeserializationError, 'CURIE support not implemented for HAL') if link_rel.eql?(CURIE_KEY)
        if link_values.is_a?(Array)
          if link_values.map{|link| link[HREF]}.any?(&:nil?)
            raise DeserializationError, 'All links must contain the href attribute'
          end
          builder.add_transition_array(link_rel, link_values)
        else
          href = link_values.delete(HREF)
          raise DeserializationError, 'All links must contain the href attribute' unless href
          builder.add_transition(link_rel, href, link_values )
        end
      end
    end

    # embedded resources are under '_embedded' in the original document, similarly to links they can
    # contain an array or a single embedded resource. An embedded resource is a full document so
    # we create a new HalDeserializer for each.
    def deserialize_embedded!(builder, media)
      embedded = media[EMBEDDED_KEY] || {}
      embedded.each do |name, value|
        if value.is_a?(Array)
          resources = value.map do |one_embedded_resource|
            HalDeserializer.new(one_embedded_resource).to_representor_hash
          end
          builder.add_embedded(name, resources)
        else
          resource_hash = HalDeserializer.new(value).to_representor_hash
          builder.add_embedded(name, resource_hash)
        end
      end
    end
  end
end
