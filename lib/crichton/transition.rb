module Crichton
  ##
  # Manages the respresentation of link elements for hypermedia messages.
  class Transition
    REL_KEY = :rel
    HREF_KEY = :href
    LINKS_KEY = :links
    METHOD_KEY = :method
    DESCRIPTORS_KEY = :descriptors
    DEFAULT_METHOD = 'GET'
    PARAMETER_FIELDS = 'url'
    ATTRIBUTE_FIELDS = 'attribute'
    URL_TEMPLATE = "%s{?%s}"

    # @example
    #   hash =  {rel: {link_property: property_name}}
    #   Transition.new(hash)
    #  It must only have one key/vale pair where the value is a hash
    #  Must contain at least the property :href
    # @param [Hash] the abstract representor hash defining a transition
    def initialize(transition_hash)
      @transition_hash = transition_hash
    end

    # @return [String] The name of the Relationship
    def rel
      @transition_hash[REL_KEY]
    end

    # @return [String] The URI for the object
    def uri
      @transition_hash[HREF_KEY]
    end
    # TODO: Elevate discussion for this method name
    alias_method :href, :uri

    def [](key)
      @transition_hash[key]
    end

    # TODO: Figure out how to scope differently
    # @return [String] The URI for the object templated against #parameters
    def templated_uri
      @templated_uri ||= if parameters.empty?
        uri
      else
        URL_TEMPLATE % [uri, parameters.map { |p| p.name }.join(",")]
      end
    end

    def templated?
      templated_uri != uri
    end

    # @return [Array] who's elements are all <Crichton:Transition> objects
    def meta_links
      meta_links ||= (@transition_hash[LINKS_KEY] || []).map do |link_key, link_href|
        Transition.new( { link_key => { href: link_href } } )
      end
    end

    # @return [String] representing the Uniform Interface Method
    def interface_method
      @interface_method ||= @transition_hash[METHOD_KEY] || DEFAULT_METHOD
    end

    # The Parameters (i.e. GET variables)
    #
    # @return [Array] who's elements are all <Crichton:Field> objects
    def parameters
      @parameters ||= get_field_by_type(PARAMETER_FIELDS)
    end

    # The Parameters (i.e. POST variables)
    #
    # @return [Array] who's elements are all <Crichton:Field> objects
    def attributes
      @attributes ||= get_field_by_type(ATTRIBUTE_FIELDS)
    end

    private

    def descriptor_fields(hash)
      hash[DESCRIPTORS_KEY].map { |k, v| Field.new({k => v }) }
    end

    def filtered_fields(fields, scope)
      fields.select { |field| field.scope == scope }
    end

    def get_field_by_type(field_type)
      fields = @transition_hash.has_key?(DESCRIPTORS_KEY) ? descriptor_fields(@transition_hash): []
      filtered_fields(fields, field_type)
    end
  end
end
