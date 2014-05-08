require 'json'

module Crichton

  class HalDeserializer

    def initialize(document_or_hash)
      if document_or_hash.is_a?(Hash)
        @json = document_or_hash
      else
        @json = JSON.parse(document_or_hash)
      end
    end

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

    def deserialize_properties(representor, json)
      property_names = json.keys.select{|key| !key.start_with?('_') }
      property_names.each do |property_name|
        representor.create_property(property_name, json[property_name])
      end
    end

    def deserialize_links(representor, json)
      links = json["_links"] || {}
      link_multiple = links.values.select {|value| value.is_a?(Array)}
      links.each do |link_name, link_values|
        if link_values.is_a?(Array)
          representor.create_link_array(link_name, link_values)
        else
          representor.create_link(link_name, link_values)
        end
      end
    end

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