require 'yaml'

module Crichton
  ##
  # Manages the respresentation of representation of
  # field options for a hypermedia message.
  class Options
  
    TYPE_KEYS = %w(external hash list)
    DEFAULT_TYPE = :list
    ID_KEY = :id
    ID_TEMPLATE = "%s_options"
    
    # @param [Hash] the abstract representation of Field Options
    def initialize(options_hash = {}, field_name='')
      @options_hash = options_hash
      @field_name = field_name
    end
  
    # @return [String] delineating the Options type
    def type
      type = TYPE_KEYS.select { |key| @options_hash.has_key?(key.to_sym) }
      type[0].to_sym || DEFAULT_TYPE 
    end
    
    # @return [Bool] indicating whether the Options can be treated as a datalist
    def datalist?
      type == :external or @options_hash.has_key?(ID_KEY)
    end
    
    # @return [String] representing a unique id for the options
    def id
        @options_hash[ID_KEY] || ID_TEMPLATE % @field_name
    end
    
    # @return [Hash] version of the Options
    def as_hash
      if type == :list
        Hash[@options_hash[:list].map {|x| [x.to_sym, x]}]
      else
        @options_hash[type]
      end
    end    
    
    # @return [Array] hash keys
    def keys
      as_hash.keys
    end
    
    # @return [Array] hash values
    def values
      as_hash.values
    end

    # @return [Array] version of the Options
    def as_list
      keys
    end
  end
end