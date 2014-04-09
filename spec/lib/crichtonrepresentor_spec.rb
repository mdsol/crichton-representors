require 'spec_helper'
require 'yaml'

module Crichton
  base_rep = "---
protocol: http
href: www.example.com/drds
id: drds
doc: A list of DRDs.
"
  describe Representor do
    it 'can instantiate object, getting a representor' do
      rhash = YAML.load(base_rep)
      Representor.new(rhash).class.to_s.should == 'Crichton::Representor'
    end
    
    it 'given a representor object, I can reference its .doc' do
      rhash = YAML.load(base_rep)
      Representor.new(rhash).doc.should == 'A list of DRDs.'
    end
    
    it 'given a representor objct, I can reference its .identifier' do
      rhash = YAML.load(base_rep)
      puts Representor.new(rhash).identifier
      Representor.new(rhash).identifier.should == 'http://www.example.com/drds'
    end

    it 'given a representor object, I can see the underlying hash with .inspect' do
      rhash = YAML.load(base_rep)
      Representor.new(rhash).inspect.should == rhash
    end
    
    it 'given a representor object, I can see the underlying hash as yaml with .to_s' do
      rhash = YAML.load(base_rep)
      Representor.new(rhash).to_s.should == base_rep
    end    
  end
end
