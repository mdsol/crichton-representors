require 'yaml'
require 'enumerable/lazy'

module Crichton
  ##
  # Manages the respresentation of hypermedia messages for different media-types.
  class Representor
    
    # @param representor_hash [Hash] the abstract representor hash defining a resource
    def initialize(representor_hash = nil)
      @representor_hash = representor_hash || {}
    end
    
    # Returns the documentfor the representor
    #
    # @return [String] the document for the representor
    def doc
      doc = @representor_hash[:doc] || ''
      @doc ||= doc
    end
    
    # The URI for the object
    #
    # @note If the URI can't be made from the provided information it constructs one fromt the Ruby ID
    # @return [String]
    def identifier
      uri = @representor_hash[:href] || self.object_id
      protocol = @representor_hash[:protocol] || (uri == self.object_id ? 'ruby_id' : 'http')
      @identifier ||= "%s://%s" % [protocol, uri]
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
    def attributes
      attributes = @representor_hash[:semantics] || {}
      @attributes ||= Hash[ attributes.map { |k,v| [ k, v[:value]] } ]
    end
    
    # @return [Enumerable] who's elements are all <Crichton:Representor> objects
    def embedded
      embedded_elements = @representor_hash[:embedded] || []
      @embedded ||= embedded_elements.lazy.map { |embed|  Representor.new(embed) }
    end
    
    def meta_links
      @meta_links ||= {}
    end
  end
end

