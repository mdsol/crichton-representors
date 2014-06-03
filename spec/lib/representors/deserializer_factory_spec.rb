require 'spec_helper'
require 'representors/deserializer_factory'

# TODO resolve with other DeserializerFactory relate spec
module Representors
  describe DeserializerFactory do
    def double_deserializer(name)
      double(name).tap do |d|
        d.stub(:iana_formats).and_return([])
        d.stub(:symbol_formats).and_return([])
      end
    end
    
    describe '.register_deserializers' do
      it 'adds a class to the registered deserializers' do
        serializer_classes = [double_deserializer('deserializer1'), double_deserializer('deserializer2')]
        DeserializerFactory.register_deserializers(*serializer_classes)
        
        expect(DeserializerFactory.registered_deserializers).to include(*serializer_classes)
      end
    end
    
    describe '.registered_deserializers' do
      it 'memoizes' do
        registered_deserializers = DeserializerFactory.registered_deserializers.object_id
        
        expect(registered_deserializers).to eq(DeserializerFactory.registered_deserializers.object_id)
      end
      
      it 'returns a frozen list of registered_deserializers' do
        expect(DeserializerFactory.registered_deserializers).to be_frozen
      end

      it 'returns registered serializers' do
        serializer_class = double_deserializer('deserializer1')
        DeserializerFactory.register_deserializers(serializer_class)

        expect(DeserializerFactory.registered_deserializers).to include(serializer_class)
      end
    end
  end
end
