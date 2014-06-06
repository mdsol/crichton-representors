require 'spec_helper'

module Representors
  module Serialization
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
    end
  end
end
