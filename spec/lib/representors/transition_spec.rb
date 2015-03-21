require 'spec_helper'
require 'yaml'
require 'uri'

module Representors
  describe Transition do
    before do
      @self_transition = {
          doc: 'Returns a list of DRDs.',
          rt: 'drds',
          type: 'safe',
          href: 'some.example.com/list',
          rel: 'self'
      }
      @search_transition = {
          doc: 'Returns a list of DRDs that satisfy the search term.',
          rt: 'drds',
          type: 'safe',
          method: 'post',
          href: '/',
          rel: 'search',
          links: {
            self: 'DRDs#drds/create',
            help: 'Forms/create'
          },
          descriptors: {
            name: {
              doc: 'Name to search',
              profile: 'http://alps.io/schema.org/Text',
              sample: 'drdname',
              scope: 'href',
              options: { list: ['one', 'two'] }
              },
            status: {
              doc: 'How is the DRD.',
              profile: 'http://alps.io/schema.org/Text',
              sample: 'renegade',
              options: { list: ['renegade', 'compliant'], id: 'status_list' }
              }
            }
        }
    end

    let(:representor_hash) { @representor_hash || @self_transition }
    let(:subject) { Transition.new(representor_hash) }

    describe '#to_s' do
      it 'retuns a string representation' do
        expect(subject.to_s).to eq(representor_hash.to_s)
      end
    end

    describe '#to_hash' do
      let(:hash_with_symbol_keys) do
        {
          href: 'some.niceplace.com/list',
          rel: 'self'
        }
      end
      let(:hash_with_string_keys) do
        {
          'href' => 'some.niceplace.com/list',
          'rel' => 'self'
        }
      end
      context 'the keys are strings' do
        let(:representor_hash) {hash_with_string_keys}
        it 'returns a hash with the keys as strings' do
          expect(subject.to_hash).to eq(hash_with_string_keys)
        end
      end
      context 'the keys are symbols' do
        let(:representor_hash) {hash_with_symbol_keys}
        it 'returns a hash with the keys as strings' do
          expect(subject.to_hash).to eq(hash_with_string_keys)
        end
      end
    end

    describe '#[]' do
      let(:representor_hash) { {key => value}}
      let(:value) { 'http://www.dontknow.com'}
      let(:key)  {'href'}

      it 'retuns the value for the keys' do
        expect(subject[key]).to eq(value)
      end

      it 'returns nil if the key is not in this transition' do
        expect(subject['Ido not exists']).to be_nil
      end

      it 'has indiferent access to the hash' do
        expect(subject[key.to_sym]).to eq(value)
        expect(subject[key.to_s]).to eq(value)
      end

    end

    describe '#has_key?' do
      let(:representor_hash) { {key => value}}
      let(:value) { 'http://www.dontknow.com'}
      let(:key)  {'href'}

      it 'retuns the value for the keys' do
        expect(subject.has_key?(key)).to eq(true)
      end

      it 'returns nil if the key is not in this transition' do
        expect(subject.has_key?('Ido not exists')).to eq(false)
      end
    end

    describe '.new' do
      it 'returns a Representors::Transition instance' do
        expect(subject).to be_an_instance_of(Transition)
      end

      describe '#rel' do
        it 'returns the transition key' do
          expect(subject.rel).to eq('self')
        end
      end

      describe '#interface_method' do
        it 'returns the uniform interface method' do
          expect(subject.interface_method).to eq('GET')
        end
        it 'retuns the interface_method provided by the hash' do
          @representor_hash = @search_transition
          expect(subject.interface_method).to eq('post')
        end
      end

      describe '#parameters' do
        it 'returns a list of fields representing the link parameters' do
          @representor_hash = @search_transition
          expect(subject.parameters.size).to eq(1)
          field = subject.parameters.first
          expect(field).to be_an_instance_of(Field)
          expect(field.scope).to eq('href')
        end
      end

      describe '#attributes' do
        it 'returns a list of fields representing the link attributes' do
          @representor_hash = @search_transition
          expect(subject.attributes.size).to eq(1)
          field = subject.attributes.first
          expect(field).to be_an_instance_of(Field)
          expect(field.scope).to eq('attribute')
        end
      end

      describe 'descriptors' do
        it 'returns a list of fields representing the link attributes' do
          @representor_hash = @search_transition
          expect(subject.descriptors.size).to eq(2)
          fields = subject.descriptors.all? { |item| item.instance_of?(Field) }
          expect(fields).to eq(true)
        end

        it 'returns params as part of the descriptors' do
          @representor_hash = @search_transition
          field = subject.descriptors.first
          expect(field).to be_an_instance_of(Field)
          expect(field.scope).to eq('attribute')
        end

        it 'returns attributes as part of the descriptors' do
          @representor_hash = @search_transition
          field = subject.descriptors[1]
          expect(field).to be_an_instance_of(Field)
          expect(field.scope).to eq('href')
        end
      end

      describe '#meta_links' do
        context 'no metalinks' do
          it 'returns an empty array' do
            expect(subject.meta_links).to eq([])
          end
        end

        it 'returns a list of Transitions' do
          @representor_hash = @search_transition
          links = subject.meta_links.all? { |item| item.instance_of?(Transition) }
          expect(links).to eq(true)
        end
        it 'returns self as the first meta link' do
          @representor_hash = @search_transition
          link = subject.meta_links[0]
          expect(link.rel).to eq(:self)
          expect(link.uri).to eq('DRDs#drds/create')
        end
        it 'returns self as the first meta link' do
          @representor_hash = @search_transition
          link = subject.meta_links[1]
          expect(link.rel).to eq(:help)
          expect(link.uri).to eq("Forms/create")
        end
      end

      describe '#uri' do
        it 'returns the bare link' do
          @representor_hash = @search_transition
          expect(subject.uri).to eq('/')
        end
      end

      describe '#templated_uri' do
        it 'returns the link parameterized' do
          @representor_hash = @search_transition
          expect(subject.templated_uri).to eq('/{?name}')
        end
      end

      describe '#templated?' do
        it 'returns true if #templated_uri != uri' do
          @representor_hash = @search_transition
          expect(subject).to be_templated
        end

        it 'returns false if #templated_uri == uri' do
          @representor_hash = @self_transition
          expect(subject).not_to be_templated
        end
      end
    end
  end
end
