require 'spec_helper'
require 'representors/serialization/serializer_base'

module Representors

  describe SerializerFactory do
    let(:factory) { Class.new(SerializerFactory) } # prevent singleton pollution from spec
  
    describe '.register_serializers' do
      it 'adds classes to the registered serializers' do
        serializer_classes = [create_serializer('serializer1'), create_serializer('serializer2')]
        factory.register_serializers(*serializer_classes)
        
        expect(factory.registered_serializers).to include(*serializer_classes)
      end
    end
    
    describe '.registered_serializers' do
      before do
        @serializer_class = create_serializer('serializer3')
        factory.register_serializers(@serializer_class)
      end
      
      it 'memoizes' do
        registered_serializers = factory.registered_serializers.object_id
        
        expect(registered_serializers).to eq(factory.registered_serializers.object_id)
      end
      
      it 'returns a frozen list of registered_serializers' do
        expect(factory.registered_serializers).to be_frozen
      end

      it 'returns registered serializers' do
        expect(factory.registered_serializers).to include(@serializer_class)
      end
    end
  end

  describe '#build' do
    let(:representor) { Representor.new({}) }
    subject(:serializer) { SerializerFactory.build(media_type, representor) }
    
    shared_examples_for 'a built serializer' do
      it 'sets the correct target in the serializer' do
        expect(serializer.target).to eq(representor)
      end
    end

    shared_examples_for 'a hal serializer' do
      it 'returns a Halserializer' do
        expect(serializer).to be_instance_of(Serialization::HalSerializer)
      end

      it_behaves_like 'a built serializer'
    end

    context 'with hal+json media type as a string' do
      let(:media_type) { 'application/hal+json' }

      it_behaves_like 'a hal serializer'
    end

    context 'with hal+json media type as a symbol' do
      let(:media_type) { :hal }

      it_behaves_like 'a hal serializer'
    end

    shared_examples_for 'a hale serializer' do
      it 'returns a Haleserializer' do
        expect(serializer).to be_instance_of(Serialization::HaleSerializer)
      end

      it_behaves_like 'a built serializer'
    end

    context 'with hale+json media type as a string' do
      let(:media_type) { 'application/vnd.hale+json' }

      it_behaves_like 'a hale serializer'
    end

    context 'with hale+json media type as a symbol' do
      let(:media_type) { :hale }

      it_behaves_like 'a hale serializer'
    end

    shared_examples_for 'an unknown media type' do
      it 'raises an unknown media type error' do
        expect { serializer }.to raise_error(UnknownMediaTypeError, "Unknown media-type: #{media_type}.")
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
