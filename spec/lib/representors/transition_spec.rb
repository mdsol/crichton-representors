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
              scope: 'url',
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
      end

      describe '#parameters' do
        it 'returns a list of fields representing the link parameters' do
          @representor_hash = @search_transition
          field = subject.parameters.first
          expect(field).to be_an_instance_of(Field)
        end
      end

      describe '#attributes' do
        it 'returns a list of fields representing the link attributes' do
          @representor_hash = @search_transition
          field = subject.attributes.first
          expect(field).to be_an_instance_of(Field)
        end
      end

      describe '#meta_links' do
        it 'returns a list of Transitions' do
          @representor_hash = @search_transition
          links = subject.meta_links.all? { |item| item.instance_of?(Transition) }
          expect(links).to be_true
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
          expect(subject.templated?).to be_true
        end

        it 'returns false if #templated_uri == uri' do
          @representor_hash = @self_transition
          expect(subject.templated?).to be_false
        end
      end
    end
  end
end
