require 'spec_helper'
require 'yaml'
require 'uri'

module Crichton

  describe Representor do
    before do
      @base_representor = {
        protocol: 'http',
        href: 'www.example.com/drds',
        id: 'drds',
        doc: 'A list of DRDs.'
        }

      @semantic_elements = {
        semantics: {
          total_count: {
            doc: 'The total count of DRDs.',
            type: 'semantic',
            profile: 'http://alps.io/schema.org/Integer',
            sample: 1,
            value: 2
            },
          uptime: {
            value: '76ms'
            },
          brackreference: {
            value: 886396728    
            }
          }
        }
    end
    let(:representor_hash) { @representor_hash || @base_representor }
    let(:subject) { Representor.new(representor_hash) }  
     
    describe '.new' do
      it 'returns a Crichton::Representor instance' do
        subject.should be_an_instance_of(Crichton::Representor)
      end
  
      it 'returns a Crichton::Representor instance with a nil argument' do
        Representor.new.should be_an_instance_of(Crichton::Representor)
      end

      describe '#doc' do
        it 'returns the same value specified under the doc element of the hash' do
          @representor_hash = {doc: 'The total count of DRDs.'}
          subject.doc.should == representor_hash[:doc]
        end
      end
      
      describe '#identifier' do
        it 'when given an href returns a url' do
          @representor_hash = {protocol: 'http', href: 'www.example.com/drds'}
          subject.identifier.should =~ URI::regexp
        end
        
        it 'when not given an href it returns ruby reference' do
          @representor_hash = {}
          subject.identifier.should == "ruby_id://%s" % subject.object_id
        end
      end     

      describe '#to_hash' do
        it 'returns a hash that it can be reconstructed with' do
          Representor.new(subject.to_hash).to_hash.should == @base_representor
        end
      end  

      describe '#to_yaml' do
        it 'returns a yaml file that represents its internal hash' do
          YAML.load(subject.to_yaml).should == @base_representor
        end
      end        

      describe '#attribute' do
        it 'returns a hash of attributes associated with the represented resource' do
          @representor_hash =  @base_representor.merge(@semantic_elements)
          attributes = subject.attributes
          semantic_elements_present =  %w(total_count uptime brackreference).all? do |key|
            attributes[key.to_sym] == @semantic_elements[:semantics][key.to_sym][:value]
          end
          semantic_elements_present.should be_true
        end
      end
      
      describe '#embedded' do
        before do
          @count = 3
          @representor_hash = @base_representor.merge(@semantic_elements)
          @representor_hash[:embedded] = [@representor_hash.clone]*@count
        end
        
        it 'returns a set of Representor objects' do
          subject.embedded.first.should be_an_instance_of(Crichton::Representor)
        end
        
        it 'returns a Representor objects that has its data' do
          embedded_objects = subject.embedded.all? do |embed|
            embed.doc == @representor_hash[:doc]
          end
          embedded_objects.should be_true
        end
        
        it 'returns the all the Representors' do
          subject.embedded.count.should == @count
        end
        
        it 'doesn\'t blow up even if nothing is embedded' do
          @representor_hash = @base_representor
          subject.embedded.count.should == 0
        end
      end
    end       
  end
end
