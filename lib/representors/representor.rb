require 'yaml'
require 'enumerable/lazy' if RUBY_VERSION < '2.0'
require 'representors/field'
require 'representors/transition'
require 'representors/serialization/serializer_factory'

module Representors
  ##
  # Manages the respresentation of hypermedia messages for different media-types.
  class Representor
    DEFAULT_PROTOCOL = 'http'
    PROTOCOL_TEMPLATE = "%s://%s"
    UNKNOWN_PROTOCOL = 'ruby_id'
    VALUE_KEY = :value
    DATA_KEY = 'data'

    # @example
    #  representor = Representors::Representor.new do |builder|
    #    builder.add_attribute({ name: => 'Bob' })
    #  end
    #
    # @param [Hash] hash the abstract representor hash defining a resource
    def initialize(hash = {})
      builder = RepresentorBuilder.new(hash)
      yield builder if block_given?
      @representor_hash = builder.to_representor_hash
    end

    # @param format to convert this representor to
    # @return the representor serialized to a particular media-type like application/hal+json
    def to_media_type(format, options={})
      SerializerFactory.build(format, self).to_media_type(options)
    end

    # Returns the documentfor the representor
    #
    # @return [String] the document for the representor
    def doc
      @doc ||= @representor_hash.doc || ''
    end

    # The URI for the object
    #
    # @note If the URI can't be made from the provided information it constructs one fromt the Ruby ID
    # @return [String]
    def identifier
      @identifier ||= begin
        uri = @representor_hash.href || self.object_id
        protocol = @representor_hash.protocol || (uri == self.object_id ? UNKNOWN_PROTOCOL : DEFAULT_PROTOCOL)
        PROTOCOL_TEMPLATE % [protocol, uri]
      end
    end

    # @return [Hash] The hash representation of the object
    def to_hash
      @to_hash ||= @representor_hash.to_h
    end

    # @return [String] the yaml representation of the object
    def to_yaml
      @to_yaml ||= YAML.dump(to_hash)
    end

    # @return [String] so the user can 'puts' this object
    def to_s
      to_hash.inspect
    end

    # @return [Hash] the resource attributes inferred from representor[:semantics]
    def properties
      @properties ||= Hash[(@representor_hash.attributes || {}).map { |k, v| [ k, v[VALUE_KEY]] }]
    end

    # @return [Enumerable] who's elements are all <Representors:Representor> objects
    def embedded
      @embedded ||= begin
        embedded_representors = (@representor_hash.embedded || {}).map do |name, values|
          if values.is_a?(Array)
            several_representors = values.map do |value|
              Representor.new(value)
            end
            [name, several_representors]
          else
            [name, Representor.new(values)]
          end
        end
        Hash[embedded_representors]
      end
    end

    # @param [String] name : name of the transition to get the data from
    # @return [Hash] hash with the contents of the data field for the transition
    def data(name)
      data_bucket = transitions.find{|transition| transition[:rel] == name}
      if data_bucket
        data_bucket[DATA_KEY]
      else
        {}
      end
    end

    # @return [Array] who's elements are all <Representors:Transition> objects
    def meta_links
      @meta_links ||= (@representor_hash.links || []).map do |k, v|
        Representors::Transition.new( { k => { href: v } } )
      end
    end

    # @return [Array] who's elements are all <Representors:Transition> objects
    def transitions
      @transitions ||= (@representor_hash.transitions || []).map { |t| Transition.new(t) }
    end

    # @return [Array] who's elements are all <Representors:Option> objects
    def datalists
      @datalists ||= begin
        attributes = transitions.map { |transition| transition.attributes }
        parameters = transitions.map { |transition| transition.parameters }
        fields = [attributes, parameters].flatten
        options = fields.map { |field| field.options }
        options.select { |o| o.datalist? }
      end
    end

  end
end
