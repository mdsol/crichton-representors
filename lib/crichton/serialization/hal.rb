
module Crichton
  module Representors
    module Serialization
      class HalSerializer
    
        MEDIA_TYPE = 'hal+json'
    
        def initialize(representor, options={})
          @options = options
          base_hash = get_semantics(representor)
          links = representor.transitions.map { |link| construct_links(link) }
          embedded = {}
          @embedded = representor.embedded
          if @embedded != {}
            links += @embedded.map { |k, v| get_embedded_links(k, v) }
            embedded = @embedded.map { |k, v| get_embedded_objects(k, v) }
            embedded = @options.has_key?(:link_only) ? {} : {_embedded: (embedded.reduce Hash.new, :merge)}
          end
          links = links != [] ? {_links: (links.reduce Hash.new, :merge) } : {}
          @serialization = base_hash.merge(links.merge(embedded))
        end
        
        def call
          @serialization
        end
        
        private
        
        def construct_links(transition)
          link = if transition.templated?
            { href:  transition.templated_uri, templated: true }
          else
            { href: transition.uri }
          end
          { transition.rel => link }
        end

        # @note: This reflects a problem with the descriptor file            
        def get_embedded_links(key, embedded)
          embedded_self = embedded.to_a.map { |embed| embed.transitions.select { |transition| transition.rel == :self } }
          links = embedded_self.flatten.map { |embed| { href: embed.uri } }
          { key =>  links }
        end
        
        def get_embedded_objects(key, embedded)
          { key =>  embedded.to_a.map { |embed| embed.to_media_type(MEDIA_TYPE, options=@options) } }
        end
        
        def get_semantics(representor)
          representor.properties
        end
        
      end
    end
  end
end