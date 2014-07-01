require 'spec_helper'

module Representors
  describe HaleDeserializer do
    it 'inherits from HalDeserializer' do
      expect(HaleDeserializer.class.ancestors.include? HalDeserializer)
    end

    it 'provides the media type application/vnd.hale+json' do
      expect(HaleDeserializer.media_types).to include('application/vnd.hale+json')
    end

    it 'provides the media symbol :hale' do
      expect(HaleDeserializer.media_symbols).to include(:hale)
    end

    describe "#to_representor" do
      it_behaves_like 'can create a representor from a hal document' do
        subject(:deserializer) {Representors::HaleDeserializer.new(document)}
      end
    end

  end
end
