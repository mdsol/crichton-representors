require 'addressable/template'

module Representors
  ##
  # Manages the respresentation of link elements for hypermedia messages.
  class Transition
    REL_KEY = :rel
    HREF_KEY = :href
    LINKS_KEY = :links
    METHOD_KEY = :method
    DESCRIPTORS_KEY = :descriptors
    DEFAULT_METHOD = 'GET'
    PARAMETER_FIELDS = 'href'
    ATTRIBUTE_FIELDS = 'attribute'
    URL_TEMPLATE = "%s{?%s}"

    # @example
    #   hash =  {rel: "self", href: "http://example.org"}
    #   Transition.new(hash)
    # Must contain at least the property :href
    # @param [Hash] the abstract representor hash defining a transition
    def initialize(transition_hash)
      @transition_hash = transition_hash
    end

    # @return [String] so the user can 'puts' this object
    def to_s
      @transition_hash.inspect
    end

    # @return [Hash] useful in cucumber steps where the feature file provides a hash
    def to_hash
      Hash[@transition_hash.map{ |k, v| [k.to_s, v] }]
    end

    # @return [String] The name of the Relationship
    def rel
      retrieve(REL_KEY)
    end

    # @return [String] The URI for the object
    def uri(data={})
      template = Addressable::Template.new(retrieve(HREF_KEY))
      template.expand(data).to_str
    end

    # @param [String] key on the transitions hash to retrieve
    # @return [String] with the value of the key
    def [](key)
      retrieve(key)
    end

    # @param [String] key on the transitions hash to retrieve
    # @return [Bool] false if there is no key
    def has_key?(key)
      !retrieve(key).nil?
    end

    # @return [String] The URI for the object templated against #parameters
    def templated_uri
      #URL as it is, it will be the templated URL of the document if it was templated
      retrieve(HREF_KEY)
    end

    def templated?
      # if we have any variable then it is not a templated url
      !Addressable::Template.new(retrieve(HREF_KEY)).variables.empty?
    end

    # @return [Array] who's elements are all <Crichton:Transition> objects
    def meta_links
      @meta_links ||= (retrieve(LINKS_KEY) || []).map do |link_key, link_href|
        Transition.new({rel: link_key, href: link_href})
      end
    end

    # @return [String] representing the Uniform Interface Method
    def interface_method
      retrieve(METHOD_KEY) || DEFAULT_METHOD
    end
    # The Parameters (i.e. GET variables)
    #
    # @return [Array] who's elements are all <Crichton:Field> objects
    # Variables in the URI template rules this method, we are going to return a field for each of them
    # if we find a field inside the 'data' of the document describing that variable, we use that information
    # else we return a field with default information about a variable.
    def parameters
      data_fields = descriptors_fields.select{|field| field.scope == PARAMETER_FIELDS }
      Addressable::Template.new(retrieve(HREF_KEY)).variables.map do |template_variable_name|
        field_specified = data_fields.find{|field| field.name.to_s == template_variable_name.to_s}
        if field_specified
          field_specified
        else
          Field.new({template_variable_name.to_sym => {type: 'string', scope: 'href'}})
        end
      end
     # descriptors_fields.select{|field| field.scope == PARAMETER_FIELDS }
    end

    # The Parameters (i.e. POST variables)
    #
    # @return [Array] who's elements are all <Crichton:Field> objects
    def attributes
      @attributes ||= descriptors_fields.select{|field| field.scope == ATTRIBUTE_FIELDS }
    end

    # The Parameters (i.e. GET variables)
    #
    # @return [Array] who's elements are all <Crichton:Field> objects
    def descriptors
      @descriptions ||= (attributes + parameters)
    end

    private

    def descriptors_fields
      @fields_hash ||= descriptors_hash.map { |k, v| Field.new({k => v }) }
    end

    def descriptors_hash
      @transition_hash[DESCRIPTORS_KEY] || []
    end

    # accept retrieving keys by symbol or string
    def retrieve(key)
      @transition_hash[key.to_sym] || @transition_hash[key.to_s]
    end

  end
end
