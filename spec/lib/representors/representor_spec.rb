require 'spec_helper'
require 'yaml'
require 'uri'

module Representors
  describe Representor do
    let(:doc) {'A list of DRDs.'}
    before do
      @base_representor = RepresentorHash.new(
        protocol: 'http',
        href: 'www.example.com/drds',
        id: 'drds',
        doc: doc
      )

      @semantic_elements = {
        attributes: {
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

      @transition_elements = {
        transitions: [
          {
            doc: 'Returns a list of DRDs.',
            rt: 'drds',
            type: 'safe',
            href: 'some.example.com/list',
            rel: 'self'
          },
          {
            doc: 'Returns a list of DRDs that satisfy the search term.',
            rt: 'drds',
            type: 'safe',
            href: '/',
            rel: 'search',
            descriptors: {
              name: {
                doc: "Name to search",
                profile: "http://alps.io/schema.org/Text",
                sample: "drdname",
                options: {'list' => ['one', 'two']}
              },
              status: {
                doc: "How is the DRD.",
                profile: "http://alps.io/schema.org/Text",
                sample: "renegade",
                options: {'list' => ['renegade', 'compliant'], 'id' => 'status_list'}
              }
            }
          }
        ]
      }
    end
    let(:representor_hash) { @representor_hash || @base_representor }
    let(:subject) { Representor.new(representor_hash) }

    describe '#to_s' do
      it 'retuns a string representation' do
        expect(subject.to_s).to eq(representor_hash.to_s)
      end
    end

    describe '.new' do
      it 'returns a Representors::Representor instance' do
        expect(subject).to be_an_instance_of(Representor)
      end

      it 'returns a Representors::Representor instance with a nil argument' do
        expect(Representor.new).to be_an_instance_of(Representor)
      end

      describe '#doc' do
        it 'returns the same value specified under the doc element of the hash' do
          @representor_hash = RepresentorHash.new
          @representor_hash.doc = doc
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
          expect(Representor.new(subject.to_hash).to_hash).to eq(@base_representor)
        end
      end

      describe '#to_yaml' do
        it 'returns a yaml file that represents its internal hash' do
          expect(YAML.load(subject.to_yaml)).to eq(@base_representor)
        end
      end

      describe '#properties' do
        it 'returns a hash of attributes associated with the represented resource' do
          @representor_hash =  @base_representor.merge(@semantic_elements)
          semantic_elements_present =  %w(total_count uptime brackreference).all? do |key|
            subject.properties[key.to_sym] == @semantic_elements[:attributes][key.to_sym][:value]
          end
          expect(semantic_elements_present).to be_true
         end
       end

      describe '#embedded' do
        let(:embedded_resource) {'embedded_resource'}
        before do
          @count = 3
          @representor_hash = @base_representor.merge(@semantic_elements)
          @representor_hash.embedded = { embedded_resource => [@representor_hash.clone]*@count}
        end

        it 'returns a set of Representor objects' do
          expect(subject.embedded[embedded_resource].first).to be_an_instance_of(Representors::Representor)
        end

        it 'returns a Representor objects that has its data' do
          embedded_objects_valid = subject.embedded[embedded_resource].all? { |embed| embed.doc == doc }
          expect(embedded_objects_valid).to be_true
        end

        it 'returns the all the Representors' do
          expect(subject.embedded[embedded_resource].count).to eq(@count)
        end

        it 'doesn\'t blow up even if nothing is embedded' do
          @representor_hash = @base_representor
          expect(subject.embedded.count).to eq(0)
        end
      end

      describe '#transitions' do
        it 'returns all transitions' do
          @representor_hash =  @base_representor.merge(@transition_elements)
          expect(subject.transitions.size).to eq(2)
          has_transitions = subject.transitions.all? { |trans| trans.instance_of?(Transition) }
          expect(has_transitions).to be_true
        end
      end

      describe '#meta_links' do
        it 'should return a list of transitions representing those links' do
          @base_representor[:links] = {
            self: 'DRDs#drds/create',
            help: 'Forms/create'
          }
          expect(subject.meta_links.size).to eq(2)
          has_meta_link = subject.meta_links.all? { |trans| trans.instance_of?(Transition) }
          expect(has_meta_link).to be_true
        end
      end

      describe '#datalists' do
        it 'returns all paramters and attributes that are members of a datalist' do
          @representor_hash =  @base_representor.merge(@transition_elements)
          has_data_list = expect(subject.datalists.first.to_hash).to eq({"renegade" => "renegade", "compliant" => "compliant"})
        end
      end
    end
  end
end
