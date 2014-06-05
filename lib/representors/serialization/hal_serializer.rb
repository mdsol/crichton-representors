require 'representors/serialization/serializer_base'

module Representors
  module Serialization
    class HalSerializer < SerializerBase
      LINKS_KEY = "_links"
      EMBEDDED_KEY = "_embedded"
      LINKS_ONLY_OPTION = :embed_links_only

      media_symbol :hal
      media_type 'application/hal+json'

      private

      def common_serialization(representor)
        base_hash = get_semantics(representor)
        embedded_links = get_embedded_links(representor)
        embedded_hals = ->(options) { get_embedded_objects(representor, options) }
        links = representor.transitions.map { |link| construct_links(link) } + embedded_links
        links = links != [] ? { LINKS_KEY => links.reduce({}, :merge) } : {}
        [base_hash, links, embedded_hals]
      end

      def serialize(representor)
        base_hash, links, embedded_hals = common_serialization(representor)
        ->(options) { base_hash.merge(links.merge(embedded_hals.(options))) }
      end

      def get_semantics(representor)
        representor.properties
      end

      def get_embedded_links(representor)
        @get_embedded_links ||= representor.embedded.map { |k, v| build_embedded_links(k, v) }
      end     

      def get_embedded_objects(representor, options)
        @get_embedded_objects ||= if representor.embedded == {} || options.has_key?(LINKS_ONLY_OPTION)
          {}
        else
          embedded_elements = representor.embedded.map { |k, v| build_embedded_objects(k, v) }
          { EMBEDDED_KEY => embedded_elements.reduce({}, :merge) }
        end
      end

      # Lambda used in this case to DRY code.  Allows 'is array' functionality to be handled elsewhere
      def build_embedded_links(key, embedded)
        find_embedded_links = ->(obj) { obj.transitions.select { |transition| transition.rel == :self } }
        embedded_self = map_or_apply(find_embedded_links, embedded)
        links = embedded_self.flatten.map { |embed| { href: embed.uri } }
        { key =>  links }
      end

      # Lambda used in this case to DRY code.  Allows 'is array' functionality to be handled elsewhere
      def build_embedded_objects(key, embedded)
        make_media_type = ->(obj) { obj.to_media_type(self.class.media_types.first) }
        embed = map_or_apply(make_media_type, embedded)
        { key =>  embed}
      end
      
      def map_or_apply(proc, obj)
        obj.is_a?(Array) ? obj.map { |sub| proc.(sub) } : proc.(obj)
      end
      
      def construct_links(transition)
        link = transition.templated? ? { href:  transition.templated_uri, templated: true } : { href: transition.uri }
        { transition.rel => link }
      end

    end
  end
end
