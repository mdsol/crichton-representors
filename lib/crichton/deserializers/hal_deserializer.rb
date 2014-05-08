require 'json'

module Crichton

  class HalDeserializer

    def initialize(document)
      @json = JSON.parse(document)
    end

    def deserialize
      representor = Representor.new
      deserialize_properties(representor, @json)
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
  end

end