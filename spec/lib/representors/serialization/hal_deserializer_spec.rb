require 'spec_helper'

describe Representors::HalDeserializer do

  it "initializes with a JSON document" do
    expect(Representors::HalDeserializer.new({}.to_json)).to be_instance_of(Representors::HalDeserializer)
  end

  it 'provides the media-type application/vnd.hal+json' do
    formats = Representors::HalDeserializer.media_types
    expect(formats).to include('application/hal+json', 'application/json')
  end

  it 'provides the media symbol :hal' do
    expect(Representors::HalDeserializer.media_symbols).to include(:hal)
  end

  describe "#to_representor" do
    it_behaves_like 'can create a representor from a hal document' do
      subject(:deserializer) {Representors::HalDeserializer.new(document)}
    end
    
    context "when the Hal deserializer recieves a Hale document" do
      it "deserializes as a Hal document and not a Hale document" do
        file = File.read("#{SPEC_DIR}/fixtures/hale_tutorial_examples/meta.json")
        hal_rep = Representors::HalDeserializer.new(file).to_representor
        place_order_link_data = hal_rep.transitions.find { |t| t[:rel] == "place_order" }#["data"]
        expect(hal_rep.properties.keys).to include('_meta')
        expect(place_order_link_data.interface_method).to eq('GET')
      end
    end
  end
  
end
