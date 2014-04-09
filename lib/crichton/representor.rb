require 'yaml'

module Crichton
  ##
  # Manages the respresentation of hypermedia messages for different media-types.
  class Representor
    def initialize(representor_hash)
      @representor = representor_hash
    end
    
    def doc
      @representor["doc"]
    end
    
    def identifier
      puts @representor
      "%s://%s" % [@representor["protocol"],@representor["href"]]
    end
    
    def inspect
      @representor
    end
      
    def to_s
      YAML.dump(@representor)
    end
    
  end
end

