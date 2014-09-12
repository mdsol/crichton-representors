require 'spec_helper'

module Representors

  describe 'Hale round trips' do
    it 'round trips a simple document' do
      hale_doc = File.read("#{SPEC_DIR}/support/basic-hale.json")
      representor = HaleDeserializer.new(hale_doc).to_representor
      serialized_representor = Serialization::HaleSerializer.new(representor).to_media_type
      #expect(JSON.parse(serialized_representor)).to eq(JSON.parse(hale_doc))
    end
  end
end
