require 'yaml'

module Crichton
  ##
  # Manages the respresentation of hypermedia fields for different media-types.
  class Field
  
    SIMPLE_METHODS = %w(name value default description type data_type)
    VALIDATORS_KEY = :validators
    OPTIONS_KEY = :options
    SCOPE_KEY = :scope
    NAME_KEY = :name
    DEFAULT_SCOPE = 'attribute'
    
    #  Hash <- {field_name: {field_property: property_name}}
    #  It must only have one key/vale pair where the value is a hash
    # @param [Hash] the abstract representation of a Field
    def initialize(field_hash)
      name = field_hash.keys.first
      @field_hash = field_hash[name].clone
      @field_hash[NAME_KEY] = name
    end

    SIMPLE_METHODS.each do |meth|
      define_method(meth) { @field_hash[meth.to_sym] }
    end
    
    # @return [String] representing the sort of field
    def scope
      @scope ||= @field_hash.has_key?(SCOPE_KEY) ? @field_hash[SCOPE_KEY] : DEFAULT_SCOPE
    end
    
    # @return [Hash] The hash representation of the object
    def to_hash
      representor_hash = @field_hash.reject {|k,v| k == NAME_KEY }
      @to_hash ||= { @field_hash[NAME_KEY] => representor_hash }
    end
    
    # @return [String] the yaml representation of the object 
    def to_yaml
      @to_yaml ||= YAML.dump(to_hash)
    end    
    
    # @return [Array] who's elements are all [Hash] objects
    def validators
      validators_normalized = []
      if @field_hash.has_key?(VALIDATORS_KEY)
        validators_normalized = @field_hash[VALIDATORS_KEY].map do |hs| 
          hs.instance_of?(Symbol) ? {hs => hs} : hs
        end
      end
      @validators ||= validators_normalized
    end
    
    # @return [Array] who's elements are all Crichton::Options objects
    def options
      @options ||= Crichton::Options.new(@field_hash[OPTIONS_KEY], name)
    end
    
    # @returns the value of the field
    def call
      value
    end
  end
end