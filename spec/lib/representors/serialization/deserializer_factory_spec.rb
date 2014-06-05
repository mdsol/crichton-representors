require 'spec_helper'
require 'representors/serialization/deserializer_factory'

# TODO resolve with other DeserializerFactory relate spec
module Representors
  describe DeserializerFactory do
    let(:subject) { Class.new(DeserializerFactory) } # prevent singleton pollution from spec
    
    describe '.register_deserializers' do
      it 'adds a classes to the registered deserializers' do
        serializer_classes = [double('deserializer1'), double('deserializer2')]
        subject.register_deserializers(*serializer_classes)
        
        expect(subject.registered_deserializers).to include(*serializer_classes)
      end
    end
    
    describe '.registered_deserializers' do
      before do
        @deserializer_class = double('deserializer3')
        subject.register_deserializers(@deserializer_class)
      end
      
      it 'memoizes' do
        registered_deserializers = subject.registered_deserializers.object_id
        
        expect(registered_deserializers).to eq(subject.registered_deserializers.object_id)
      end
      
      it 'returns a frozen list of registered_deserializers' do
        expect(DeserializerFactory.registered_deserializers).to be_frozen
      end

      it 'returns registered serializers' do
        expect(subject.registered_deserializers).to include(@deserializer_class)
      end
    end
  end
end
