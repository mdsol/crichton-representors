module Crichton
  ##
  # Manages the respresentation of hypermedia messages for different media-types.
  class Golem

    attr_reader :properties
    def initialize
      @properties = {}
    end

    def create_property(name, value)
      @properties[name] = value
    end

    def method_missing(method, *args, &block)
      if @properties.has_key?(method.to_s)
        @properties[method.to_s]
      else
        super
      end
    end
  end

end

