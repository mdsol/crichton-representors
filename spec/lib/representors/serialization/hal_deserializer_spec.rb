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
  end
end
