require 'spec_helper'
require 'yaml'
require 'uri'

#TODO: This should only test functionality of this class and not repeat the file hal_spec
module Representors
  describe Serialization::HaleSerializer do
    before do
      @base_representor = {
        protocol: 'http',
        href: 'www.example.com/drds',
        id: 'drds',
        doc: 'doc'
      }
    end

    subject(:serializer) { SerializerFactory.build(:hale, Representor.new(document)) }

    shared_examples "a hale documents attributes" do |representor_hash, media|
      let(:document) { representor_hash.merge(@base_representor) }
      
      representor_hash[:attributes].each do |k, v|
        it "includes the document attribute #{k} and associated value" do
          expect(serializer.to_media_type(media)[k]).to eq(v[:value])
        end
      end
    end

    shared_examples "a hale documents links" do |representor_hash, media|
      let(:document) { representor_hash.merge(@base_representor) }
      
      representor_hash[:transitions].each do |item|
        it "includes the document transition #{item}" do
          expect(serializer.to_media_type(media)["_links"][item[:rel]][:href]).to eq(item[:href])
        end
      end
    end

    shared_examples "a hale documents embedded hale documents" do |representor_hash, media|
      let(:document) { representor_hash.merge(@base_representor) }
      
      representor_hash[:embedded].each do |embed_name, embed|
        embed[:attributes].each do |k, v|
          it "includes the document attribute #{k} and associated value" do
            expect(serializer.to_media_type(media)["_embedded"][embed_name][k]).to eq(v[:value])
          end
        end
        embed[:transitions].each do |item|
          it "includes the document attribute #{item} and associated value" do
            expect(serializer.to_media_type(media)["_embedded"][embed_name]["_links"][item[:rel]][:href]).to eq(item[:href])
          end
        end
      end
    end

    shared_examples "a hale documents embedded collection" do |representor_hash, media|
      let(:document) { representor_hash.merge(@base_representor) }
      
      representor_hash[:embedded].each do |embed_name, embeds|
        embeds.each_with_index do |embed, index|
          embed[:attributes].each do |k, v|
            it "includes the document attribute #{k} and associated value" do
              expect(serializer.to_media_type(media)["_embedded"][embed_name][index][k]).to eq(v[:value])
            end
          end
          embed[:transitions].each do |item|
            it "includes the document attribute #{item} and associated value" do
              expect(serializer.to_media_type(media)["_embedded"][embed_name][index]["_links"][item[:rel]][:href]).to eq(item[:href])
            end
          end
        end
      end
    end

    media = {}    # TODO: get rid of media
    describe '#to_media_type' do
      context 'Document that is empty' do
        let(:document) { {} }

        it 'returns a hash with no attributes, links or embedded resources' do
          expect(serializer.to_media_type(media)).to be_empty
        end
      end

      context 'Document with only properties' do
        representor_hash = {
          attributes:
            {
            'title' => {value: 'The Neverending Story'},
            'author' => {value: 'Michael Ende'},
            'pages' => {value: '396'}
            }}

        it_behaves_like 'a hale documents attributes', representor_hash, media
      end

      context 'Document with properties and links' do
        representor_hash = {
          attributes:
            {
              'title' => {value: 'The Neverending Story'},
              },
          transitions: [
                {
                href: '/mike',
                rel: 'author',
                }
              ]
            }

        it_behaves_like 'a hale documents attributes', representor_hash, media
        it_behaves_like 'a hale documents links', representor_hash, media
      end

      context 'Document with properties, links, and embedded' do
        representor_hash = {
          attributes: {
              'title' => {value: 'The Neverending Story'},
          },
          transitions: [
            {
              href: '/mike',
              rel: 'author',
            }
          ],
          embedded: {
            'embedded_book' => {attributes: {'content' => { value: 'A...' } }, transitions: [{rel: 'self', href: '/foo'}]}
          }
        }
        
        it_behaves_like 'a hale documents attributes', representor_hash, media
        it_behaves_like 'a hale documents links', representor_hash, media
        it_behaves_like 'a hale documents embedded hale documents', representor_hash, media
      end

      context 'Document with an embedded collection' do
        representor_hash = {
          attributes: {
              'title' => {value: 'The Neverending Story'},
          },
          transitions: [
            {
              href: '/mike',
              rel: 'author',
            }
          ],
          embedded: {
            'embedded_book' => [
              {attributes: {'content' => { value: 'A...' } }, transitions: [{rel: 'self', href: '/foo1'}]},
              {attributes: {'content' => { value: 'B...' } }, transitions: [{rel: 'self', href: '/foo2'}]},
              {attributes: {'content' => { value: 'C...' } }, transitions: [{rel: 'self', href: '/foo3'}]}
            ]
          }
        }
        
        it_behaves_like 'a hale documents attributes', representor_hash, media
        it_behaves_like 'a hale documents links', representor_hash, media
        it_behaves_like 'a hale documents embedded collection', representor_hash, media
      end

      context 'Document has a link data objects' do
        let(:representor_hash) do 
          { 
            transitions: [
              {
              href: '/mike',
              rel: 'author',
              method: 'post',
              descriptors: {
                'name' => {
                  'type' => 'text',
                  'scope' => 'href',
                  'value' => 'Bob',
                  :options => {'list' => ['Bob', 'Jane', 'Mike'], 'id' => 'names'},
                  'required' => 'True'
                  }
                }
              }
            ]
          }
        end
        let(:document) { representor_hash.merge(@base_representor) }
        let(:serialized_result) { serializer.to_media_type }

        after do
          expect(@result_element).to eq(@document_element)
        end

        it 'returns the correct link method' do
          @result_element = serialized_result["_links"]['author'][:method]
          @document_element = document[:transitions].first[:method]
        end
        
        it 'returns the correct type keyword in link data' do
          @result_element = serialized_result["_links"]['author'][:data]['name']['type']
          @document_element = document[:transitions].first[:descriptors]['name']['type']
          end
        
        it 'returns the correct scope keyword in link data' do
          @result_element = serialized_result["_links"]['author'][:data]['name']['scope']
          @document_element = document[:transitions].first[:descriptors]['name']['scope']
        end
        
        it 'returns the correct value keyword in link data' do
          @result_element = serialized_result["_links"]['author'][:data]['name']['value']
          @document_element = document[:transitions].first[:descriptors]['name']['value']
        end
        
        it 'returns the correct datalists' do
          @result_element = serialized_result["_meta"]['names']
          @document_element = document[:transitions].first[:descriptors]['name'][:options]['list']
        end
        
        it 'returns the correct required in link data' do
          @result_element = serialized_result["_links"]['author'][:data]['name']['required']
          @document_element = document[:transitions].first[:descriptors]['name']['required']
        end        
        
        it 'properly references the datalists' do
          @result_element = serialized_result["_links"]['author'][:data]['name'][:options]['_ref']
          @document_element = ['names']
        end  

      end
    end
  end
end
