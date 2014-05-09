require 'yaml'
require 'enumerable/lazy' if RUBY_VERSION < '2.0'

module Crichton
  ##
  # Manages the respresentation of hypermedia messages for different media-types.
  class Representor
    DOC_KEY = :doc
    LINK_KEY = :href
    PROTOCOL_KEY = :protocol
    SEMANTIC_KEY = :semantics
    EMBEDDED_KEY = :embedded
    META_KEY = :links
    TRANSITION_KEY = :transitions
    VALUE_KEY = :value
    UNKNOWN_PROTOCOL = 'ruby_id'
    DEFAULT_PROTOCOL = 'http'
    PROTOCOL_TEMPLATE = "%s://%s"
    
    
    # @param representor_hash [Hash] the abstract representor hash defining a resource
    def initialize(representor_hash = nil)
      @representor_hash = representor_hash || {}
    end
    
    # Returns the documentfor the representor
    #
    # @return [String] the document for the representor
    def doc
      @doc ||= @representor_hash[DOC_KEY] || ''
    end
    
    # The URI for the object
    #
    # @note If the URI can't be made from the provided information it constructs one fromt the Ruby ID
    # @return [String]
    def identifier
      @identifier ||= begin
        uri = @representor_hash[LINK_KEY] || self.object_id
        protocol = @representor_hash[PROTOCOL_KEY] || (uri == self.object_id ? UNKNOWN_PROTOCOL : DEFAULT_PROTOCOL)
        PROTOCOL_TEMPLATE % [protocol, uri]
      end
    end
    
    # @return [Hash] The hash representation of the object
    def to_hash
      @to_hash ||= @representor_hash
    end
    
    # @return [String] the yaml representation of the object 
    def to_yaml
      @to_yaml ||= YAML.dump(@representor_hash)
    end
    
    # @return [Hash] the resource attributes inferred from representor[:semantics]
    def properties
      @properties ||= Hash[(@representor_hash[SEMANTIC_KEY] || {}).map { |k, v| [ k, v[VALUE_KEY]] }]
    end
    
    # @return [Enumerable] who's elements are all <Crichton:Representor> objects
    def embedded
      @embedded ||= (@representor_hash[EMBEDDED_KEY] || []).lazy.map { |embed|  Representor.new(embed) }
    end
    
    # @return [Array] who's elements are all <Crichton:Transition> objects
    def meta_links
      @meta_links ||= get_transitions((@representor_hash[META_KEY] || []).map { |k, v| { k => { href: v } } })
    end
    
    # @return [Array] who's elements are all <Crichton:Transition> objects    
    def transitions
      @transitions ||= begin
        transitions = (@representor_hash[TRANSITION_KEY] || []).map { |k, v| {k => v} }
        get_transitions(transitions)
      end
    end

    # @return [Array] who's elements are all <Crichton:Option> objects    
    def datalists
      @datalists ||= begin
        attributes = transitions.map { |transition| transition.attributes }
        parameters = transitions.map { |transition| transition.parameters }
        fields = [attributes, parameters].flatten
        options = fields.map { |field| field.options }
        options.select { |o| o.datalist? }
      end
    end
    
    private
    
    def get_transitions(hash)  
      hash.map { |h| Crichton::Transition.new(h) }
    end
  end
end

