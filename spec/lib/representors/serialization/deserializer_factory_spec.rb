require 'spec_helper'
require 'representors/serialization/deserializer_factory'

# TODO resolve with other DeserializerFactory relate spec
module Representors
  module Serialization
    describe DeserializerFactory do
      let(:factory) { Class.new(DeserializerFactory) } # prevent singleton pollution from spec
  
      describe '.register_deserializers' do
        it 'adds classes to the registered deserializers' do
          serializer_classes = [double('deserializer1'), double('deserializer2')]
          factory.register_deserializers(*serializer_classes)
  
          expect(factory.registered_deserializers).to include(*serializer_classes)
        end
      end
  
      describe '.registered_deserializers' do
        before do
          @deserializer_class = double('deserializer3')
          factory.register_deserializers(@deserializer_class)
        end
  
        it 'memoizes' do
          registered_deserializers = factory.registered_deserializers.object_id
  
          expect(registered_deserializers).to eq(factory.registered_deserializers.object_id)
        end
  
        it 'returns a frozen list of registered_deserializers' do
          expect(factory.registered_deserializers).to be_frozen
        end
  
        it 'returns registered serializers' do
          expect(factory.registered_deserializers).to include(@deserializer_class)
        end
      end
  
      describe '#build' do
        let(:document) { {}.to_json }
        subject(:deserializer) { DeserializerFactory.build(media_type, document) }
        
        shared_examples_for 'a built deserializer' do
          it 'sets the correct target in the deserializer' do
            expect(deserializer.target).to eq({})
          end
        end
        
        shared_examples_for 'a hal deserializer' do
          it 'returns a HalDeserializer' do
            expect(deserializer).to be_instance_of HalDeserializer
          end
  
          it_behaves_like 'a built deserializer'
        end
        
        context 'with hal+json media type as a string' do
          let(:media_type) { 'application/hal+json' }
  
          it_behaves_like 'a hal deserializer'
        end
  
        context 'with hal+json media type as a symbol' do
          let(:media_type) { :hal }
  
          it_behaves_like 'a hal deserializer'
        end
  
        shared_examples_for 'a hale deserializer' do
          it 'returns a HaleDeserializer' do
            expect(deserializer).to be_instance_of HaleDeserializer
          end
  
          it_behaves_like 'a built deserializer'
        end
  
        context 'with hale+json media type as a string' do
          let(:media_type) { 'application/vnd.hale+json' }
  
          it_behaves_like 'a hale deserializer'
        end
  
        context 'with hale+json media type as a symbol' do
          let(:media_type) { :hale }
  
          it_behaves_like 'a hale deserializer'
        end
        
        shared_examples_for 'an unknown media type' do
          it 'raises an unknown media type error' do
            expect { deserializer }.to raise_error(UnknownMediaTypeError, "Unknown media-type: #{media_type}.")
          end
        end
  
        context 'unknown media type string' do
          let(:media_type) { 'unknown' }
          
          it_behaves_like 'an unknown media type'
        end
  
        context 'unknown media type symbol' do
          let(:media_type) { :unknown }
  
          it_behaves_like 'an unknown media type'
        end
      end
    end
  end
end
