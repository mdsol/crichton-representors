require 'yaml'

module Crichton
  ##
  # Manages the respresentation of hypermedia messages for different media-types.
  class Options
  
    # @param [Hash] the abstract representation of Field Options
    def initialize(options_hash = {}, field_name='')
      @options_hash = options_hash
    end
  
    # @return [String] delineating the Options type
    def type
      if @options_hash.has_key?(:external)
        :external
      elsif @options_hash.has_key?(:hash)
        :hash
      else
        :list     
      end
    end
    
    # @return [Bool] indicating whether the Options can be treated as a datalist
    def datalist?
      type == :external or @options_hash.has_key?(:id)
    end
    
    # @return [String] representing a unique id for the options
    def id
      if @options_hash.has_key?(:id)
        @options_hash[:id]
      else
        "%s_options" % field_name
      end
    end
    
    # @return [Hash] version of the Options
    def as_hash
      if type == :list
        Hash[@options_hash[:list].map {|x| [x.to_sym, x]}]
      elsif type == :hash
        @options_hash[:hash]
      else
        @options_hash[:external]
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