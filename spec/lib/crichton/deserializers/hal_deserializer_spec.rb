require 'spec_helper'

describe Crichton::HalDeserializer do
  subject(:deserializer) {Crichton::HalDeserializer.new(document)}

  it "initializes with a JSON document" do
    expect(Crichton::HalDeserializer.new({}.to_json)).to be_instance_of (Crichton::HalDeserializer)
  end

  describe "#to_s" do
    let(:document) { {"property" => "value"}.to_json }

    it "outputs a string representation of the document" do
      expect(deserializer.to_s).to eq("{\"property\"=>\"value\"}")
    end
  end

  describe "#deserialize" do
    context "empty document" do
      let(:document) { {}.to_json }
      it "creates a representor with no properties" do
        expect(deserializer.deserialize.properties).to be_empty
      end
    end

    context "A HAL document with properties" do
      let(:properties_hash) { {"who" => "he", "when" => "yesterday"} }
      let(:document) { properties_hash.to_json }
      it "creates a representor with the properties of the HAL document" do
        expect(deserializer.deserialize.properties).to eq(properties_hash)
      end
    end

  end

end