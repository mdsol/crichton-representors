require 'spec_helper'
require 'yaml'

module Crichton
  base_rep = "---
protocol: http
href: www.example.com/drds
id: drds
doc: A list of DRDs.
"
  semantic_elements = "---
semantics:
  total_count:
    doc: The total count of DRDs.
    type: semantic
    profile: http://alps.io/schema.org/Integer
    sample: 1
    value: 2
  uptime:
    value: 76ms
  brackreference: 
    value: 886396728    
"

  describe Representor do
    context 'when I instantiate Representor' do
      rhash = YAML.load(base_rep)
      subject { Representor.new(rhash) }
      it { should be_an_instance_of Crichton::Representor}
      its(:doc) { should == rhash["doc"] }
      its(:identifier) { should == 'http://www.example.com/drds' }
      its(:inspect) { should == rhash }
      its(:to_s) { should == base_rep }
    end
    
    context 'when the representor_hash has semantics' do
      context '.attribute' do
        semelements = YAML.load(semantic_elements)
        rhash = YAML.load(base_rep).merge(semelements)
        subject { Representor.new(rhash).attributes }
        ['total_count', 'uptime', 'brackreference'].each do |key|
          its([key]) { should == semelements['semantics'][key]['value'] }
        end
      end
    end       
    
    context 'when the representor_hash has embedded resources' do
      context '.embedded' do
        semelements = YAML.load(semantic_elements)
        combinedhash = YAML.load(base_rep).merge(semelements)
        rhash = combinedhash.clone
        rhash['embedded'] = [combinedhash]*3
        subject { Representor.new(rhash).embedded }
        its(:count) { should == 3 }
        its("first.doc") { should == combinedhash["doc"] }
        its("first.inspect") { should == combinedhash }
      end
    end       
    
  end
end
