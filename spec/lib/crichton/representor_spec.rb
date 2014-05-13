require 'spec_helper'
require 'yaml'
require 'uri'

module Crichton
  module Representors
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
            reference: {
              value: 'Fort::4652'
            }
          }
        }
      
        @transition_elements = {
          transitions: {
            self: {
              doc: 'Returns a list of DRDs.',
              rt: 'drds',
              type: 'safe',
              href: 'some.example.com/list'
            },
            search: {
              doc: 'Returns a list of DRDs that satisfy the search term.',
              rt: 'drds',
              type: 'safe',
              href: '/',
              descriptors: {
                name: {
                  doc: "Name to search",
                  profile: "http://alps.io/schema.org/Text",
                  sample: "drdname",
                  options: {list: ['one', 'two']}
                },
                status: {
                  doc: "How is the DRD.",
                  profile: "http://alps.io/schema.org/Text",
                  sample: "renegade",
                  options: {list: ['renegade', 'compliant'], id: 'status_list'}
                }
              }
            }
          }
        }
      end
      let(:representor_hash) { @representor_hash || @base_representor }
      let(:subject) { Representor.new(representor_hash) }  
     
      describe '.new' do
        it 'returns a Crichton::Representor instance' do
          subject.should be_an_instance_of(Representor)
        end
  
        it 'returns a Crichton::Representor instance with a nil argument' do
          Representor.new.should be_an_instance_of(Representor)
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

        describe '#properties' do
          it 'returns a hash of attributes associated with the represented resource' do
            @representor_hash =  @base_representor.merge(@semantic_elements)
            semantic_elements_present =  %w(total_count reference).all? do |key|
              print subject.attributes
              subject.attributes[key.to_sym] == @semantic_elements[:semantics][key.to_sym][:value]
            end
            semantic_elements_present.should be_true
           end
         end
      
        describe '#embedded' do
          before do
            @count = 3
            @representor_hash = @base_representor.merge(@semantic_elements)
            @representor_hash[:embedded] = {items: [@representor_hash.clone]*@count }
          end
        
          it 'returns a set of Representor objects' do
            subject.embedded[:items].first.should be_an_instance_of(Representor)
          end
        
          it 'returns a Representor objects that has its data' do
            embedded_objects_valid = subject.embedded[:items].all? { |embed| embed.doc == representor_hash[:doc] }
            embedded_objects_valid.should be_true
          end
        
          it 'returns the all the Representors' do
            subject.embedded[:items].count.should == @count
          end
        
          it 'doesn\'t blow up even if nothing is embedded' do
            @representor_hash = @base_representor
            subject.embedded.count.should == 0
          end
        end
      
        describe '#transitions' do
          it 'returns all transitions' do
            @representor_hash =  @base_representor.merge(@transition_elements)
            subject.transitions.should have(2).items
            has_transitions = subject.transitions.all? { |trans| trans.instance_of?(Transition) }
            has_transitions.should be_true
          end
        end
      
        describe '#meta_links' do
          it 'should return a list of transitions representing those links' do
            @base_representor[:links] = {
              self: 'DRDs#drds/create',
              help: 'Forms/create'
            }
            subject.meta_links.should have(2).items
            has_meta_link = subject.meta_links.all? { |trans| trans.instance_of?(Transition) }
            has_meta_link.should be_true
          end
        end
      
        describe '#datalists' do
          it 'returns all paramters and attributes that are members of a datalist' do
            @representor_hash =  @base_representor.merge(@transition_elements)
            has_data_list = subject.datalists.first.as_hash.should == {renegade: "renegade", compliant: "compliant"}
          end
        end
      end       
    end
  end
end
