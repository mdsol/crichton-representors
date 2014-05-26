require 'spec_helper'
require 'yaml'
require 'uri'

module Representors
  describe Representor do
    before do

      @base_representor = {
          protocol: 'http',
          href: 'www.example.com/drds',
          id: 'drds',
          doc: 'doc'
        }
    end

    subject(:serializer) { Representor.new(RepresentorHash.new(document)) }
    
    top_level_media = %w(application text)
    media_types = %w(hal vnd.hal)
    formats = %w(json yaml)   
       
    media_requests = media_types.product(formats).product(top_level_media).map do |media, top_level| 
      med, format = media
      "#{top_level}/#{med}+#{format}"
    end    
    
    shared_examples "a hal documents attributes" do |representor_hash, media|
      let(:document) { representor_hash.merge(@base_representor) }
      representor_hash[:attributes].each do |k, v|
        it "has the document attribute #{k} and associated value" do
          expect(serializer.to_media_type(media)[k]).to eq(v[:value])
        end
      end
    end
    
    shared_examples "a hal documents links" do |representor_hash, media|
      let(:document) { representor_hash.merge(@base_representor) }
      representor_hash[:transitions].each do |item|
        it "has the document transition #{item}" do
          expect(serializer.to_media_type(media)[:_links][item[:rel]][:href]).to eq(item[:href])
        end
      end
    end
    
    shared_examples "a hal documents ebedded hal documents" do |representor_hash, media|
      let(:document) { representor_hash.merge(@base_representor) }
      representor_hash[:embedded].each do |embed_name, embed|
        embed[:attributes].each do |k, v|
          it "has the document attribute #{k} and associated value" do
            print 'moo!', serializer.to_media_type(media)
            expect(serializer.to_media_type(media)[:_embedded][embed_name][k]).to eq(v[:value])
          end
        end      
        embed[:transitions].each do |item|
          it "has the document attribute #{item} and associated value" do
            expect(serializer.to_media_type(media)[:_embedded][embed_name][:_links][item[:rel]][:href]).to eq(item[:href])
          end
        end
      end
    end
    
    shared_examples "a hal documents ebedded collection" do |representor_hash, media|
      let(:document) { representor_hash.merge(@base_representor) }
      representor_hash[:embedded].each do |embed_name, embeds|
        embeds.each_with_index do |embed, index|
          embed[:attributes].each do |k, v|
            it "has the document attribute #{k} and associated value" do
              expect(serializer.to_media_type(media)[:_embedded][embed_name][index][k]).to eq(v[:value])
            end
          end      
          embed[:transitions].each do |item|
            it "has the document attribute #{item} and associated value" do
              expect(serializer.to_media_type(media)[:_embedded][embed_name][index][:_links][item[:rel]][:href]).to eq(item[:href])
            end
          end
        end
      end
    end
        
    #media_requests.each do |media|
    media = 'application/hal+json'
    describe "#to_media_type(%s)" % media do
      context "empty document" do
        let(:document) { {} }
        
        it "returns a hash with no attributes, links or embedded resources" do
          expect(@base_representor).to_not be_nil
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
        
        it_behaves_like "a hal documents attributes", representor_hash, media
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
        
        it_behaves_like "a hal documents attributes", representor_hash, media
        it_behaves_like "a hal documents links", representor_hash, media
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
        it_behaves_like "a hal documents attributes", representor_hash, media
        it_behaves_like "a hal documents links", representor_hash, media
        it_behaves_like "a hal documents ebedded hal documents", representor_hash, media
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
        it_behaves_like "a hal documents attributes", representor_hash, media
        it_behaves_like "a hal documents links", representor_hash, media
        it_behaves_like "a hal documents ebedded collection", representor_hash, media
      end     
    end
  end
end