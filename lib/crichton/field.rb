require 'yaml'

module Crichton
  ##
  # Manages the respresentation of hypermedia messages for different media-types.
  class Field

    # @param [Hash] the abstract representation of a Field
    def initialize(field_hash = {})
      name = field_hash.keys.first
      field_hash[name][:name] = name
      @field_hash = field_hash[name]
    end

    %w(name value default description type data_type).each do |meth|
      define_method(meth) { @field_hash[meth.to_sym] }
    end
    
    # @return [String] representing the sort of field
    def scope
      @scope ||= @field_hash.has_key?(:scope) ? @field_hash[:scope] : 'attribute'
    end
    
    # @return [Hash] The hash representation of the object
    def to_hash
      @to_hash ||= { @field_hash[:name] => @field_hash }
    end
    
    # @return [String] the yaml representation of the object 
    def to_yaml
      @to_yaml ||= YAML.dump(to_hash)
    end    
    
    # @return [Array] who's elements are all [Hash] objects
    def validators
      validators_normalized = []
      if @field_hash.has_key?(:validators)
        validators_normalized = @field_hash[:validators].map do |hs| 
          hs.instance_of?(Symbol) ? {hs => hs} : hs
        end
      end
      @validators ||= validators_normalized
    end
    
    # @return [Array] who's elements are all Crichton::Options objects
    def options
      @options ||= Crichton::Options.new(@field_hash[:options], name)
    end
    
    # @returns the value of the field
    def call
      value
    end
  end
end