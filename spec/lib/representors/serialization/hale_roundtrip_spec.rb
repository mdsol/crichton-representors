require 'spec_helper'

module Representors

  describe 'Hale round trips' do
    it 'round trips a simple document' do
      deserialized_representor = HaleDeserializer.new(File.read("#{SPEC_DIR}/support/basic-hale.json")).to_representor
      serialized_hale = Serialization::HaleSerializer.new(deserialized_representor).to_media_type
      redeserialized_representor = HaleDeserializer.new(serialized_hale).to_representor
      reserialized_hale = Serialization::HaleSerializer.new(redeserialized_representor).to_media_type
      expect(serialized_hale).to eq(reserialized_hale)
    end

    it 'round trips a complex document' do
      deserialized_representor = HaleDeserializer.new(File.read("#{SPEC_DIR}/fixtures/complex_hale_document.json")).to_representor
      serialized_hale = Serialization::HaleSerializer.new(deserialized_representor).to_media_type
      redeserialized_representor = HaleDeserializer.new(serialized_hale).to_representor
      reserialized_hale = Serialization::HaleSerializer.new(redeserialized_representor).to_media_type
      expect(serialized_hale).to eq(reserialized_hale)
    end

  end
end
