

module Crichton
  ##
  # Manages the respresentation of hypermedia messages for different media-types.
  class Transition

    # @param [Hash] the abstract representor hash defining a transition
    def initialize(transition_hash = nil)
      rel = transition_hash.first[0]
      transition_hash[rel][:rel] = rel
      @transition_hash = transition_hash[rel] || {}
    end
    
    # @return [String] The name of the Relationship
    def rel
      @rel ||= @transition_hash[:rel]
    end
    
    # @return [String] The URI for the object
    def uri
      @uri ||= @transition_hash[:href]
    end
    
    
    # TODO: Figure out how to scope differently
    # @return [String] The URI for the object templated against #parameters
    def templated_uri
      @templated_uri ||= "%s?%s" % [uri, parameters.map { |p| "{%s}" % p.name }.join("&")]
    end
    
    # @return [Array] who's elements are all <Crichton:Transition> objects
    def meta_links
      simple_link_to_link = ->(hash) { hash.map { |k,v| { k => {href: v } } } }
      generate_transition = ->(hash) { simple_link_to_link.(hash).map { |h| Transition.new(h) } }
      @meta_links ||= @transition_hash.has_key?(:links) ? generate_transition.(@transition_hash[:links]) : []
    end
    
    # @return [String] representing the Uniform Interface Method
    def interface_method
      @interface_method ||= @transition_hash.has_key?(:method) ? @transition_hash[:method] : 'GET'
    end    
    
    # The Parameters (i.e. GET variables)
    #
    # @return [Array] who's elements are all <Crichton:Field> objects
    def parameters
      fields = @transition_hash.has_key?(:descriptors) ? descriptor_fields(@transition_hash) : []
      @parameters ||= filtered_fields(fields, 'url')
    end    

    # The Parameters (i.e. POST variables)
    #
    # @return [Array] who's elements are all <Crichton:Field> objects    
    def attributes
      fields = @transition_hash.has_key?(:descriptors) ? descriptor_fields(@transition_hash): []     
      @attributes ||= filtered_fields(fields, 'attribute')
    end        
    
    private
    
    def descriptor_fields(hash)
      hash[:descriptors].map { |k, v| Field.new({k => v }) }
    end

    def filtered_fields(fields, scope)
      fields.select { |field| field.scope == scope }
    end
  end
end