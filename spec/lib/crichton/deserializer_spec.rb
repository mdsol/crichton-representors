require 'spec_helper'

describe Crichton::Deserializer do

  describe 'Initializer' do
    let(:document) { {}.to_json }
    subject(:deserializer) { Crichton::Deserializer.create(format, document)}

    context 'Requesting a hal JSON format' do
      let(:format) {'application/hal+json'}
      it 'returns a HalDeserializer' do
        expect(deserializer).to be_instance_of(Crichton::HalDeserializer)
      end
    end

    context 'Requesting a hale JSON format' do
      let(:format) {'application/vnd.hale+json'}
      it 'returns a HalDeserializer' do
        expect(deserializer).to be_instance_of(Crichton::HalDeserializer)
      end
    end

    context 'Requesting Hale JSON and some encoding' do
      let(:format) {'application/vnd.hale+json encoding=UTF8'}
      it 'returns a HalDeserializer' do
        expect(deserializer).to be_instance_of(Crichton::HalDeserializer)
      end
    end

    context 'Requesting an unknown format' do
      let(:format) {'application/i_make_no_sense_to_crichton'}
      it 'raises an exception' do
        expect{deserializer}.
          to raise_error(Crichton::UnknownFormatError, "Crichton can not deserialize #{format}")
      end
    end

  end

end
