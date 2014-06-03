require 'spec_helper'

module Representors
  describe SerializerFactory do
    def double_serializer(name)
      double(name).tap do |s|
        s.stub(:iana_formats).and_return([])
        s.stub(:symbol_formats).and_return([])
      end
    end
    
    describe '.register_serializers' do
      it 'adds a class to the registered serializers' do
        serializer_classes = [double_serializer('serializer1'), double_serializer('serializer2')]
        SerializerFactory.register_serializers(*serializer_classes)
        
        expect(SerializerFactory.registered_serializers).to include(*serializer_classes)
      end
    end
    
    describe '.registered_serializers' do
      it 'memoizes' do
        registered_serializers = SerializerFactory.registered_serializers.object_id
        
        expect(registered_serializers).to eq(SerializerFactory.registered_serializers.object_id)
      end
      
      it 'returns a frozen list of registered_serializers' do
        expect(SerializerFactory.registered_serializers).to be_frozen
      end

      it 'returns registered serializers' do
        serializer_class = double_serializer('serializer1')
        SerializerFactory.register_serializers(serializer_class)

        expect(SerializerFactory.registered_serializers).to include(serializer_class)
      end
    end
  end
end
