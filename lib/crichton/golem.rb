module Crichton
  ##
  # Manages the respresentation of hypermedia messages for different media-types.
  class Golem < BagOfProperties

    attr_reader :properties, :links, :embedded_resources

    def initialize
      @properties = {}
      @links = BagOfProperties.new
      @embedded_resources = BagOfProperties.new
    end

    def create_property(name, value)
      @properties[name] = value
    end

    def create_link(link_name, values)
      @links[link_name] = BagOfProperties.new(values)
    end

    def create_link_array(link_name, array_of_links)
      @links[link_name] = array_of_links.map {|link_properties| BagOfProperties.new(link_properties)}
    end

    def create_embedded(name, embedded_resource)
      @embedded_resources[name] = embedded_resource
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
