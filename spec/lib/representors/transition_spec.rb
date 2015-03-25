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
          href: '/{?name}',
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
          expect(field.name).to eq(:name)
        end
        context 'there are no params' do
          let(:transition) do
            {
            href: 'some.example.com',
            rel: 'filter'
            }
          end
          it 'returns an empty array' do
            expect(Transition.new(transition).parameters).to eq([])
          end
        end
        context 'the uri template has information we do not have in data' do
          let(:transition) do
            {
            href: 'some.place.com{?name,localization}',
            rel: 'filter',
            descriptors: {
              name: {
                doc: name_doc,
                type: 'Integer',
                profile: name_profile,
                scope: 'href'
                },
              localization: {
                doc: 'wrong scope',
                type: 'Something crazy',
                profile: 'Because this key has no scope should not be used'
                }
              }
            }
          end
          let(:name_doc) {'di place of Trusmis'}
          let(:name_profile) {'http://alps.io/schema.org/Text'}

          it 'returns all the variables in the uri template' do
            expect(Transition.new(transition).parameters.size).to eq(2)
          end
          it 'returns the information about the variable described by the document' do
            param = Transition.new(transition).parameters.find{|param| param.name == :name}
            expect(param.scope).to eq('href')
            expect(param.type).to eq('Integer')
          end
          it 'returns default information for the variable not described by the document' do
            param = Transition.new(transition).parameters.find{|param| param.name == :localization}
            expect(param.scope).to eq('href')
            expect(param.type).to eq('string')
          end
        end
      end

      describe '#attributes' do
        it 'returns a list of fields representing the link attributes' do
          @representor_hash = @search_transition
          expect(subject.attributes.size).to eq(1)
          field = subject.attributes.first
          expect(field).to be_an_instance_of(Field)
          expect(field.scope).to eq('attribute')
          expect(field.name).to eq(:status)
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
        context 'the url does not have a template variable in the url' do
          let(:transition) do
            {
            href: 'some.example.com',
            rel: 'filter'
            }
          end
          context 'params provided' do
            it 'returns the url as it is' do
              expect(Transition.new(transition).uri(uuid: 'uuid')).to eq(transition[:href])
            end
          end
          context 'params not provided' do
            it 'returns the url as it is' do
              expect(Transition.new(transition).uri).to eq(transition[:href])
            end
          end
        end

        context 'the url has template variables in the base url and the query parameters' do
          let(:transition) do
            {
            href: 'some.example.com/{uuid}?first_param=goodstuff{&filter}',
            rel: 'filter'
            }
          end
          let(:uuid) { SecureRandom.uuid}
          let(:filter) {'cows'}
          let(:full_url) {"some.example.com/#{uuid}?first_param=goodstuff&filter=cows"}
          let(:not_templated_url) {'some.example.com/?first_param=goodstuff'}

          it 'allows to create the url with the correct parameters' do
            expect(Transition.new(transition).uri(uuid: uuid, filter: filter)).to eq(full_url)
          end
          it 'returns the url without template variables when there are no params' do
            expect(Transition.new(transition).uri).to eq(not_templated_url)
          end
          it 'returns the url without template variables when the params does not match the template variable' do
            expect(Transition.new(transition).uri(stuff: filter)).to eq(not_templated_url)
          end
        end
      end

      describe '#templated_uri' do
        context 'the transition has a templated url' do
          let(:transition) do
            {
            href: 'some.example.com/{uuid}?first_param=goodstuff{&filter}',
            rel: 'filter'
            }
          end
          it 'returns the templated url' do
            expect(Transition.new(transition).templated_uri).to eq(transition[:href])
          end
        end
        context 'the transition has a non-templated url' do
          let(:transition) do
            {
            href: 'some.example.com',
            rel: 'filter'
            }
          end
          it 'returns the url' do
            expect(Transition.new(transition).templated_uri).to eq(transition[:href])
          end
        end
      end

      describe '#templated?' do
        context 'the transition has a templated url' do
          let(:transition) do
            {
            href: 'some.example.com/{uuid}?first_param=goodstuff{&filter}',
            rel: 'filter'
            }
          end
          it 'returns true' do
            expect(Transition.new(transition)).to be_templated
          end
        end
        context 'the transition has a non-templated url' do
          let(:transition) do
            {
            href: 'some.example.com',
            rel: 'filter'
            }
          end
          it 'returns false' do
            expect(Transition.new(transition)).not_to be_templated
          end
        end
      end
    end
  end
end
