require 'json'

module Crichton

  # Deserializes the HAL format. For examples of how this format looks like check the files under
  # spec/fixtures/hal
  class HalDeserializer

    # Can be initialized with a json document(string) or an already parsed hash
    # @params document or hash
    def initialize(document_or_hash)
      if document_or_hash.is_a?(Hash)
        @json = document_or_hash
      else
        @json = JSON.parse(document_or_hash)
      end
    end

    # Returns back a class with all the information of the document and with convenience methods
    # to access it.
    def deserialize
      representor = Golem.new
      deserialize_properties(representor, @json)
      deserialize_links(representor, @json)
      deserialize_embedded(representor, @json)
      representor
    end

    def to_s
      @json.to_s
    end

    private

    # Properties are normal JSON keys in the document. Create properties in the resulting object
    def deserialize_properties(representor, json)
      # TODO: only take out _links and _embedded
      property_names = json.keys.select{|key| !key.start_with?('_') }
      property_names.each do |property_name|
        representor.create_property(property_name, json[property_name])
      end
    end

    # links are under '_links' in the original document. Links always have a key (its name) but
    # the value can be a hash with its properties or an array with several links.
    def deserialize_links(representor, json)
      links = json["_links"] || {}
      links.each do |link_name, link_values|
        if link_values.is_a?(Array)
          representor.create_link_array(link_name, link_values)
        else
          representor.create_link(link_name, link_values)
        end
      end
    end

    # embedded resources are under '_embedded' in the original document, similarly to links they can
    # contain an array or a single embedded resource. An embedded resource is a full document so
    # we create a new HalDeserializer for each.
    def deserialize_embedded(representor, json)
       embedded = json["_embedded"] || {}
       embedded.each do |name, value|
         if value.is_a?(Array)
           resources = value.map do |one_embedded_resource|
             HalDeserializer.new(one_embedded_resource).deserialize
           end
           representor.create_embedded(name, resources)
         else
           new_representor = HalDeserializer.new(value).deserialize
           representor.create_embedded(name, new_representor)
         end
       end
    end

  end
end