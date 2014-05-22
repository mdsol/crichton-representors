require 'spec_helper'

module Representors
RSpec.describe Deserializer do
  subject(:deserializer) {Deserializer.build(format, document)}

  context 'hal+json format' do
    let(:format) {'application/hal+json' }
    let(:document) { {}.to_json}
    it 'returns a HalDeserializer' do
      expect(deserializer).to be_instance_of HalDeserializer
    end
    it 'the HalDeserializer has the correct document' do
      expect(deserializer.document).to eq({})
    end
  end

  context ':hale format' do
    let(:format) {:hale }
    let(:document) { {}.to_json}
    it 'returns a HaleDeserializer' do
      expect(deserializer).to be_instance_of HaleDeserializer
    end
    it 'the HalDeserializer has the correct document' do
      expect(deserializer.document).to eq({})
    end
  end

  context 'unknown format string' do
    let(:format) { 'Iamunknown'}
    let(:document) { {}.to_json}
    it 'Raises an unknown format error' do
      expect{deserializer}.to raise_error(UnknownFormatError, "Crichton can not deserialize #{format}")
    end
  end

  context 'unknown format symbol' do
    let(:format) { :Iamunknown}
    let(:document) { {}.to_json}
    it 'Raises an unknown format error' do
      expect{deserializer}.to raise_error(UnknownFormatError, "Crichton can not deserialize #{format}")
    end
  end

end

end