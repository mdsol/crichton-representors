module Representors
  module Serialization
    class HaleSerializer < HalSerializer
      @media_types = ['vnd.hale', 'hale']
      @formats = ['json', 'yaml']      
      
      private
      
    end
  end
end