require 'yaml'

module Representors
  module Serialization
    class HalSerializer
  
      LINKS_KEY = "_links"
      EMBEDDED_KEY = "_embedded"
        
      @media_types = %w(hal)
      @formats = %w(json yaml)

      def self.media_types
        @media_types
      end
      
      def self.formats
        @formats
      end
              
      def initialize(representor, media_type, options = {})
        @media_type = media_type
        @serialization = serialize(representor)
      end
      
      def to_media_type(options)
        @serialization.(options)
      end
              
      def as_media_type(format, options)
        media_format(to_media_type(options), format)
      end
      
      private
      
      def media_format(object, format)
        formatters = {
            'yaml' => ->(obj) { obj.to_yaml },
            'json' => ->(obj) { obj.to_json }
          }
        formatters[format].(object)
      end
      
      def common_serialization(representor)
        base_hash = get_semantics(representor)
        embedded_links, embedded_hals = get_embedded_elements(representor)
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
                     
      def get_embedded_elements(representor)
        @get_embedded_elements ||= begin
          unless representor.embedded == {}
            embedded = representor.embedded
            links = embedded.map { |k, v| get_embedded_links(k, v) }
            _embedded = embedded.map { |k, v| get_embedded_objects(k, v) }
            embedded_hals = ->(options) { options.has_key?(:link_only) ? {} : { EMBEDDED_KEY => _embedded.reduce({}, :merge) } }
            [links, embedded_hals]
          else
            [[], ->(o) { {} }]
          end
        end
      end
              
      def get_embedded_links(key, embedded)
        if embedded.is_a?(Array)
          embedded_self = embedded.to_a.map { |embed| embed.transitions.select { |transition| transition.rel == :self } }
          links = embedded_self.flatten.map { |embed| { href: embed.uri } }
        else
          embedded_self = embedded.transitions.select { |transition| transition.rel == 'self' } 
          links = embedded_self.flatten.map { |embed| { href: embed.uri } }
        end
        { key =>  links }
      end
      
      def get_embedded_objects(key, embedded)
        if embedded.is_a?(Array)
          embed = embedded.to_a.map { |embed| embed.to_media_type(@media_type) }
        else
          embed = embedded.to_media_type(@media_type)
        end
        { key =>  embed}
      end
              
      def construct_links(transition)
        link = if transition.templated?
          { href:  transition.templated_uri, templated: true }
        else
          { href: transition.uri }
        end
        { transition.rel => link }
      end
              
    end
  end
end
