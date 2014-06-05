module Representors
  ##
  # Manages the respresentation of
  # field options for a hypermedia message.
  class Options
    TYPE_KEYS = %w(external hash list)
    LIST_TYPE = 'list'
    EXTERNAL_TYPE = 'external'
    HASH_TYPE = 'hash'
    DEFAULT_TYPE = LIST_TYPE
    ID_KEY = 'id'
    ID_TEMPLATE = "%s_options"

    # @param [Hash] the abstract representation of Field Options
    def initialize(options_hash = {}, field_name = '')
      @options_hash = options_hash || {}
      @field_name = field_name
    end

    # @return [String] delineating the Options type
    def type
      @type ||= begin
        type_keys = TYPE_KEYS.detect { |key| @options_hash.has_key?(key) }
        type_keys || DEFAULT_TYPE
      end
    end

    # @return [Bool] indicating whether the Options can be treated as a datalist
    def datalist?
      type == EXTERNAL_TYPE || @options_hash.has_key?(ID_KEY)
    end

    # @return [String] representing a unique id for the options
    def id
      @options_hash[ID_KEY] || ID_TEMPLATE % @field_name
    end

    # @return [Hash] version of the Options
    def to_hash
      type == LIST_TYPE ? Hash[(@options_hash[LIST_TYPE] || {}).map { |x| [x, x] }] : @options_hash[type]
    end

    # @return [Array] hash keys
    def keys
      to_hash.keys
    end

    # @return [Array] hash values
    def values
      to_hash.values
    end

    # @return [Array] version of the Options
    def to_list
      keys
    end
    
    def to_data
      type == HASH_TYPE || type == EXTERNAL_TYPE ? to_hash : to_list
    end
    
  end
end
