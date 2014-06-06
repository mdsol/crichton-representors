require 'spec_helper'
require 'representors/serialization/deserializer_factory'

#TODO make specs for individual deserializers under deserializer directory
module Representors
  describe DeserializerFactory do
    subject(:deserializer) { DeserializerFactory.build(format, document) }
  
    context 'hal+json format' do
      let(:format) {'application/hal+json' }
      let(:document) { {}.to_json}
      
      it 'returns a HalDeserializer' do
        expect(deserializer).to be_instance_of HalDeserializer
      end
      it 'the HalDeserializer has the correct document' do
        expect(deserializer.target).to eq({})
      end
    end
  
    context ':hale format' do
      let(:format) {:hale }
      let(:document) { {}.to_json}
      
      it 'returns a HaleDeserializer' do
        expect(deserializer).to be_instance_of HaleDeserializer
      end
      it 'the HalDeserializer has the correct target' do
        expect(deserializer.target).to eq({})
      end
    end
  
    context 'unknown format string' do
      let(:format) { 'Iamunknown'}
      let(:document) { {}.to_json}
      
      it 'Raises an unknown format error' do
        expect{deserializer}.to raise_error(UnknownMediaTypeError, "Unknown media-type: #{format}.")
      end
    end
  
    context 'unknown format symbol' do
      let(:format) { :Iamunknown}
      let(:document) { {}.to_json}
      
      it 'Raises an unknown format error' do
        expect{deserializer}.to raise_error(UnknownMediaTypeError, "Unknown media-type: #{format}.")
      end
    end
  end
end
