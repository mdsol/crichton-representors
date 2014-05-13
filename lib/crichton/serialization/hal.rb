
module Crichton
  module Representors
    module Serialization
      class HalSerializer
    
        @media_types = ['vnd.hal', 'hal']
        @formats = ['json']

        def self.media_types
          @media_types
        end
        
        def self.formats
          @formats
        end
                
        def initialize(representor, options = { called_media: 'hal+json' })
          @options = options
          @serialization = serialize(representor)
        end
        
        def to_media_type(options)
          @serialization
        end
                
        def as_media_type(options)
          to_media_type.to_json
        end
        
        private
        
        def serialize(representor)
          base_hash = get_semantics(representor)
          embedded_links, embedded_hals = get_embedded_elements(representor)
          links = (representor.transitions.map { |link| construct_links(link) })+embedded_links
          links = links != [] ? { _links: links.reduce({}, :merge) } : {}
          base_hash.merge(links.merge(embedded_hals))
        end
        
        def get_semantics(representor)
          representor.attributes
        end
                       
        def get_embedded_elements(representor)
          @get_embedded_elements ||= begin
            unless representor.embedded == {}
              embedded = representor.embedded
              links = embedded.map { |k, v| get_embedded_links(k, v) }
              _embedded = embedded.map { |k, v| get_embedded_objects(k, v) }
              embedded_hals = @options.has_key?(:link_only) ? {} : { _embedded: _embedded.reduce({}, :merge) }
              [links, embedded_hals]
            else
              [[], {}]
            end
          end
        end
                
        def get_embedded_links(key, embedded)
          embedded_self = embedded.to_a.map { |embed| embed.transitions.select { |transition| transition.rel == :self } }
          links = embedded_self.flatten.map { |embed| { href: embed.uri } }
          { key =>  links }
        end
        
        def get_embedded_objects(key, embedded)
          { key =>  embedded.to_a.map { |embed| embed.to_media_type(@options[:called_media], options=@options) } }
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
end