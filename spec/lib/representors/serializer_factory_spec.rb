require 'spec_helper'

module Representors
  describe SerializerFactory do
    let(:subject) { Class.new(SerializerFactory) } # prevent singleton pollution from spec
    
    describe '.register_serializers' do
      it 'adds classes to the registered serializers' do
        serializer_classes = [double('serializer1'), double('serializer2')]
        subject.register_serializers(*serializer_classes)
        
        expect(subject.registered_serializers).to include(*serializer_classes)
      end
    end
    
    describe '.registered_serializers' do
      before do
        @serializer_class = double('serializer3')
        subject.register_serializers(@serializer_class)
      end
      
      it 'memoizes' do
        registered_serializers = subject.registered_serializers.object_id
        
        expect(registered_serializers).to eq(subject.registered_serializers.object_id)
      end
      
      it 'returns a frozen list of registered_serializers' do
        expect(subject.registered_serializers).to be_frozen
      end

      it 'returns registered serializers' do
        expect(subject.registered_serializers).to include(@serializer_class)
      end
    end
  end
end
