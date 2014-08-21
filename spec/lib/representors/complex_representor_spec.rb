require 'spec_helper'
require 'yaml'
require 'uri'
require 'fixtures/complex_hash'
module Representors
  describe Representor do
    before do
      @representor_hash = ComplexRepresentor::COMPLEX_REPRESENTOR
    end
    let(:representor_hash) { @representor_hash }
    
    let(:subject) { Representor.new(representor_hash) }

    describe '.new' do
      it 'returns a Representors::Representor instance' do
        expect(subject).to be_an_instance_of(Representor)
      end

      describe '#to_s' do
        it 'retuns a string representation' do
          expect(eval(subject.to_s)).to eq(representor_hash)
        end
      end

      describe '#doc' do
        it 'returns the same value specified under the doc element of the hash' do
          doc = 'Describes the semantics, states and state transitions associated with DRDs.'
          expect(subject.doc).to eq(doc)
        end
      end

      describe '#identifier' do
        it 'when given an href returns a url' do
          @representor_hash = RepresentorHash.new(protocol: 'http', href: 'www.example.com/drds')
          expect(subject.identifier).to match(URI::regexp)
        end

        it 'when not given an href it returns ruby reference' do
          @representor_hash = RepresentorHash.new
          expect(subject.identifier).to eq("ruby_id://%s" % subject.object_id)
        end
      end

      describe '#to_hash' do
        it 'returns a hash that it can be reconstructed with' do
          expect(Representor.new(subject.to_hash).to_hash).to eq(@representor_hash)
        end
      end

      describe '#to_yaml' do
        it 'returns a yaml file that represents its internal hash' do
          expect(YAML.load(subject.to_yaml)).to eq(YAML::load(YAML.dump(@representor_hash)))
        end
      end

      describe '#properties' do
        it 'returns a hash of attributes associated with the represented resource' do
          semantic_elements_present =  %w(total_count items).all? do |key|
            subject.properties[key.to_sym] == @representor_hash[:attributes][key.to_sym][:value]
          end
          expect(semantic_elements_present).to be_true
         end
       end

      describe '#embedded' do
        let(:embedded_resource) {:items}
        before do
          @count = 1
        end

        it 'returns a set of Representor objects' do
          expect(subject.embedded[embedded_resource].first).to be_an_instance_of(Representors::Representor)
        end

        it 'returns a Representor objects that has its data' do
          doc = 'Diagnostic Repair Drones or DRDs are small robots that move around Leviathans. They are built by a Leviathan as it grows.'
          embedded_objects_valid = subject.embedded[embedded_resource].all? { |embed| embed.doc == doc }
          expect(embedded_objects_valid).to be_true
        end

        it 'returns the all the Representors' do
          expect(subject.embedded[embedded_resource].count).to eq(@count)
        end
      end

      describe '#transitions' do
        it 'returns all transitions' do
          expect(subject.transitions.size).to eq(4)
          has_transitions = subject.transitions.all? { |trans| trans.instance_of?(Transition) }
          expect(has_transitions).to be_true
        end
      end

      describe '#meta_links' do
        it 'should return a list of transitions representing those links' do
          expect(subject.meta_links.size).to eq(2)
          has_meta_link = subject.meta_links.all? { |trans| trans.instance_of?(Transition) }
          expect(has_meta_link).to be_true
        end
      end

      describe '#datalists' do
        let(:embedded_resource) {:items}
        it 'returns all paramters and attributes that are members of a datalist' do
          has_data_list = expect(subject.embedded[embedded_resource].first.datalists.count).to eq(4)
        end
      end
      
      describe '.transitions' do
        describe '#to_s' do
          it 'retuns a string representation' do
            expect(subject.transitions.first.to_s).to eq(representor_hash[:transitions].first.to_s)
          end
        end

        describe '#to_hash' do
          it 'retuns a hash representation' do
            hashed = Hash[subject.transitions.first.to_hash.map{|(k,v)| [k.to_sym,v]}]
            expect(hashed).to eq(representor_hash[:transitions].first)
          end
        end

        describe '#[]' do
          let(:key)  {'href'}
          let(:value) {representor_hash[:transitions].first[key.to_sym]}
          it 'retuns the value for the keys' do
            expect(subject.transitions.first[key]).to eq(value)
          end

          it 'returns nil if the key is not in this transition' do
            expect(subject.transitions.first['Ido not exists']).to be_nil
          end

          it 'has indiferent access to the hash' do
            expect(subject.transitions.first[key.to_sym]).to eq(value)
            expect(subject.transitions.first[key.to_s]).to eq(value)
          end

        end


        describe '#rel' do
          it 'returns the transition key' do
            expect(subject.transitions.first.rel).to eq(representor_hash[:transitions].first[:rel])
          end
        end

        describe '#interface_method' do
          it 'returns the uniform interface method' do
            expect(subject.transitions.first.interface_method).to eq('GET')
          end
        end

        describe '#parameters' do
          it 'returns a list of fields representing the link parameters' do
            field = subject.transitions[2].parameters.first
            expect(field).to be_an_instance_of(Field)
          end
        end

        describe '#attributes' do
          it 'returns a list of fields representing the link attributes' do
            field = subject.transitions.last.attributes.first
            expect(field).to be_an_instance_of(Field)
          end
        end

        describe '#meta_links' do
          it 'returns a list of Transitions' do
            links = subject.transitions.first.meta_links.all? { |item| item.instance_of?(Transition) }
            expect(links).to be_true
          end
        end

        describe '#uri' do
          it 'returns the bare link' do
            expect(subject.transitions.first.uri).to eq('www.example.com/drds')
          end
        end

        describe '#templated_uri' do
          it 'returns the link parameterized' do
            expect(subject.transitions[2].templated_uri).to eq('www.example.com/drds/search{?search_term,name}')
          end
        end

        describe '#templated?' do
          it 'returns true if #templated_uri != uri' do
            expect(subject.transitions.first.templated?).to be_false
          end

          it 'returns false if #templated_uri == uri' do
            expect(subject.transitions[2].templated?).to be_true
          end
        end
        describe '.field' do
          before do
            @field = subject.transitions.last.attributes.first
            @field_hash = {:name => representor_hash[:transitions].last[:descriptors][:name]}
          end
        
          it 'returns a Representors::Field instance' do
            expect(@field).to be_an_instance_of(Representors::Field)
          end

          describe '#to_hash' do
            it 'returns its constructor hash' do
              expect(@field.to_hash).to eq(@field_hash)
            end
          end

          describe '#to_yaml' do
            it 'returns its constructor hash represented as a yaml document' do
              expect(@field.to_yaml).to eq(YAML.dump(@field_hash))
            end
          end

          describe '#name' do
            it 'returns the key when requesting the name' do
              expect(@field.name).to eq(@field_hash.keys.first)
            end
          end

          %w(value default description type data_type).map(&:to_sym).each do |key|
            describe "\##{key}" do
              it "returns it's hash value" do
               expect(@field.send(key)).to eq(@field_hash.first[1][key])
              end
            end
          end
        end
      end
      
      describe '#to_media_type' do
        it 'serializes to hale' do
          puts subject.to_media_type(:hale)
        end
      end
    end
  end
end
    