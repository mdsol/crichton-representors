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
        # we want to group by rel name because it is possible to have several transitions with the same
        # rel name. This will become an array in the output. For instance an items array
        # with links to each item
        grouped_transitions = representor.transitions.group_by{|transition| transition[:rel]}
        links = build_links(grouped_transitions) + embedded_links
        links = links.empty? ? {} : { LINKS_KEY => links.reduce({}, :merge) }
        [base_hash, links, embedded_hals]
      end

      def setup_serialization(representor)
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
        @get_embedded_objects ||= if representor.embedded.empty? || options.has_key?(LINKS_ONLY_OPTION)
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

      # @param [Hash] transitions. A hash on the shape "rel_name" => [Transition]
      # The value for the rel_name usually will have only one transition but when we are building an
      # array of transitions will have many.
      # @return [Array] Array of hashes with the format [ { rel_name => {link_info1}}, {rel_name2 => ... }]
      def build_links(transitions)
        transitions.map do |rel_name, transition_array|
          links = transition_array.map{|transition| build_links_for_this_media_type(transition)}
          if links.size > 1
            {rel_name => links}
          else
            {rel_name => links.first}
          end
        end
      end

      # This method can be overriden by other classes
      # @param transition , a single tansition
      def build_links_for_this_media_type(transition)
        link = if transition.templated?
          { href:  transition.templated_uri, templated: true }
        else
          { href: transition.uri }
        end
        link[:method] = transition.interface_method
        link
      end
    end
  end
end
