require 'json'

module Crichton

  # Deserializes the HAL format as specified in http://stateless.co/hal_specification.html
  # For examples of how this format looks like check the files under spec/fixtures/hal
  # TODO: support Curies http://www.w3.org/TR/2010/NOTE-curie-20101216/
  class HalDeserializer

    LINKS_KEY = '_links'
    EMBEDDED_KEY = '_embedded'
    CURIE_KEY = 'curies'

    # Can be initialized with a json document(string) or an already parsed hash
    # @params document or hash
    def initialize(document_or_hash)
      if document_or_hash.is_a?(Hash)
        @json = document_or_hash
      else #This may raise with a Json parse error which is ok
        @json = JSON.parse(document_or_hash)
      end
    end

    def to_hash
      @builder = Representors::RepresentorBuilder.new
      deserialize_properties
      deserialize_links
      #  deserialize_embedded(representor, @json)
      @builder.to_representor_hash
    end

    # Returns back a class with all the information of the document and with convenience methods
    # to access it.
    def to_representor
      Representor.new(to_hash)
    end

    private
    # Properties are normal JSON keys in the HAL document. Create properties in the resulting object
    def deserialize_properties
      # links and embedded are not properties but keywords of HAL, skipping them.
      property_names = @json.keys.select do |key|
        (key != LINKS_KEY) && (key != EMBEDDED_KEY)
      end
      property_names.each do |property_name|
        @builder.add_attribute(property_name, @json[property_name])
      end
    end

    # links are under '_links' in the original document. Links always have a key (its name) but
    # the value can be a hash with its properties or an array with several links.
    def deserialize_links
      links = @json["_links"] || {}
      links.each do |link_rel, link_values|
        raise DeserializationError, "CURIE support not implemented for HAL" if link_rel.eql?(CURIE_KEY)
        if link_values.is_a?(Array)
          if link_values.map{|link| link['href']}.any?(&:nil?)
            raise DeserializationError, 'All links must contain the href attribute'
          end
          @builder.add_transition_array(link_rel, link_values)
        else
          href = link_values.delete('href')
          raise DeserializationError, 'All links must contain the href attribute' unless href
          @builder.add_transition(link_rel, href, link_values )
        end
      end
    end
=begin
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
=end
  end
end
