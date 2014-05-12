require 'crichton/serialization/hal'

module Crichton
  module Representors
    module Serialization
    
      SERIALIZERS = {'hal+json' => :HalSerializer}
    
      def to_media_type(media_type, options={})
        Serialization.const_get('%s' % SERIALIZERS[media_type]).new(self, options).()
      end
    end
  end
end