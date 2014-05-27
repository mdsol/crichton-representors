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
    media_types = %w(hale vnd.hale)
    formats = %w(json yaml)   
       
    media_requests = media_types.product(formats).product(top_level_media).map do |media, top_level| 
      med, format = media
      "#{top_level}/#{med}+#{format}"
    end    
 
     shared_examples "a hale documents attributes" do |representor_hash, media|
      let(:document) { representor_hash.merge(@base_representor) }
      representor_hash[:attributes].each do |k, v|
        it "has the document attribute #{k} and associated value" do
          expect(serializer.to_media_type(media)[k]).to eq(v[:value])
        end
      end
    end
    
    shared_examples "a hale documents links" do |representor_hash, media|
      let(:document) { representor_hash.merge(@base_representor) }
      representor_hash[:transitions].each do |item|
        it "has the document transition #{item}" do
          expect(serializer.to_media_type(media)["_links"][item[:rel]][:href]).to eq(item[:href])
        end
      end
    end
    
    shared_examples "a hale documents embedded hale documents" do |representor_hash, media|
      let(:document) { representor_hash.merge(@base_representor) }
      representor_hash[:embedded].each do |embed_name, embed|
        embed[:attributes].each do |k, v|
          it "has the document attribute #{k} and associated value" do
            expect(serializer.to_media_type(media)[:_embedded][embed_name][k]).to eq(v[:value])
          end
        end      
        embed[:transitions].each do |item|
          it "has the document attribute #{item} and associated value" do
            expect(serializer.to_media_type(media)[:_embedded][embed_name]["_links"][item[:rel]][:href]).to eq(item[:href])
          end
        end
      end
    end
    
    shared_examples "a hale documents embedded collection" do |representor_hash, media|
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
              expect(serializer.to_media_type(media)[:_embedded][embed_name][index]["_links"][item[:rel]][:href]).to eq(item[:href])
            end
          end
        end
      end
    end
        
    media = 'application/hale+json'    
    describe "#to_media_type(%s)" % media do
      context "empty document" do
        let(:document) { {} }
        
        it "returns a hash with no attributes, links or embedded resources" do
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
        
        it_behaves_like "a hale documents attributes", representor_hash, media
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
        
        it_behaves_like "a hale documents attributes", representor_hash, media
        it_behaves_like "a hale documents links", representor_hash, media
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
        it_behaves_like "a hale documents attributes", representor_hash, media
        it_behaves_like "a hale documents links", representor_hash, media
        it_behaves_like "a hale documents embedded hale documents", representor_hash, media
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
        it_behaves_like "a hale documents attributes", representor_hash, media
        it_behaves_like "a hale documents links", representor_hash, media
        it_behaves_like "a hale documents embedded collection", representor_hash, media
      end
          
      context 'Document has a link data objects' do
        #render?
        #data?
        representor_hash = {
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
        let(:document) { representor_hash.merge(@base_representor) }
        it 'properly returns the link method' do
          test_path = ->(result) { result["_links"]['author'][:method] }
          descriptor_path = ->(doc) { doc[:transitions].first[:method] }
          expect(test_path.(serializer.to_media_type(media))).to eq(descriptor_path.(document))  
        end
        it 'properly represents the type keyword in link data' do
          test_path = ->(result) { result["_links"]['author'][:data]['name']['type'] }
          descriptor_path = ->(doc) { doc[:transitions].first[:descriptors]['name']['type'] }
          expect(test_path.(serializer.to_media_type(media))).to eq(descriptor_path.(document))  
        end
        it 'properly represents the scope keyword in link data' do
          test_path = ->(result) { result["_links"]['author'][:data]['name']['scope'] }
          descriptor_path = ->(doc) { doc[:transitions].first[:descriptors]['name']['scope'] }
          expect(test_path.(serializer.to_media_type(media))).to eq(descriptor_path.(document)) 
        end	 
        it 'properly represents the value keyword in link data' do
          test_path = ->(result) { result["_links"]['author'][:data]['name']['value'] }
          descriptor_path = ->(doc) { doc[:transitions].first[:descriptors]['name']['value'] }
          expect(test_path.(serializer.to_media_type(media))).to eq(descriptor_path.(document))         
        end
        it 'properly represents the datalists' do
          test_path = ->(result) { result["_meta"]['names'] }
          descriptor_path = ->(doc) { doc[:transitions].first[:descriptors]['name'][:options]['list'] }
          expect(test_path.(serializer.to_media_type(media))).to eq(descriptor_path.(document))        
        end   
        it 'properly references the datalists' do
          test_path = ->(result) { result["_links"]['author'][:data]['name'][:options]['_ref'] }
          expect(test_path.(serializer.to_media_type(media))).to eq(['names'])        
        end   
        it 'properly represents the required in link data' do
          test_path = ->(result) { result["_links"]['author'][:data]['name']['required'] }
          descriptor_path = ->(doc) { doc[:transitions].first[:descriptors]['name']['required'] }
          expect(test_path.(serializer.to_media_type(media))).to eq(descriptor_path.(document))         
        end
        
      end
      
      #  it 'properly represents the method keyword' do
      #  end    
    end
  end
end
