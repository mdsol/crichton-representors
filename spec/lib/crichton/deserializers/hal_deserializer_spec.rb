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
    let(:golem) { deserializer.deserialize }

    context "empty document" do
      let(:document) { {}.to_json }

      it "returns a golem with no properties" do
        expect(golem.properties).to be_empty
      end

      it "returns a golem with no links" do
        expect(golem.links).to be_empty
      end
    end

    context "A HAL document with properties and no links" do
      let(:properties_hash) { {"who" => "he", "when" => "yesterday"} }
      let(:document) { properties_hash.to_json }

      it "returns a golem with the properties of the HAL document" do
        expect(golem.properties).to eq(properties_hash)
      end

      it "returns a golem with no links" do
        expect(golem.links).to be_empty
      end
    end

    context "A HAL document with only a self link" do
      let(:document) { fixture('hal/SelfLinkOnly.json') }

      it "returns a golem with no properties" do
        expect(golem.properties).to be_empty
      end

      it "returns a golem with the self link of the document" do
        expect(golem.links['self']).to eq({'href'=> '/example_resource'})
      end
    end

    context "A HAL document with properties and simple links" do
      let(:document) { fixture('hal/SimpleLinksAndAttributes.json') }

      it "returns a golem with the properties in the HAL document" do
        expect(golem.currentlyProcessing).to eq(14)
        expect(golem.shippedToday).to eq(20)
      end

      it "returns a golem with the self link of the document" do
        expect(golem.links['self']).to eq({'href'=> '/orders'})
      end

      it "returns a golem with a next link of the document" do
        expect(golem.links.next).to eq({'href'=> '/orders?page=2'})
      end

      it "it returns a golem with the array of links in the document" do
        expect(golem.links['ea:admin'][0]).to eq({ "href"=> "/admins/2", "title" => "Fred"})
        expect(golem.links['ea:admin'][1]).to eq({ "href"=> "/admins/5", "title" => "Kate"})
        expect(golem.links['ea:admin'][2]).to eq(nil)
      end
    end

    context "A HAL document with properties, embedded objects and complex links" do
      let(:document) { fixture('hal/HalAllLinkObjectProperties.json') }

      it "returns a golem which can access all the properties of links" do
        link = golem.links.testrel
        {"href"=>"http://example.org/api/user/test",
        "templated"=>true,
        "type"=>"some-type",
        "deprecation"=>"http://very-deprecated.com",
        "name"=>"some-name",
        "profile"=>"some-profile",
        "title"=>"A Great Title",
        "hreflang"=>"en-US"}.each do |key, value|
          expect(link[key]).to eq(value)
        end
      end

      it "returns a golem with the properties in the HAL document" do
        expect(golem.properties['some-property']).to eq(123)
      end

      it "returns a golem with all the embedded objects" do
        expect(golem.embedded_resources.size).to eq(2)
      end

      it "retuns a golem to access the properties of the embedded object" do
        expect(golem.embedded_resources.embedded1.properties['some-property']).to eq(1234)
      end

      it "returns a golem to access the links of the embedded object" do
        link = golem.embedded_resources.embedded1.links.testrel
        {"href"=>"http://example.org/api/user/test",
        "templated"=>true,
        "type"=>"some-type",
        "deprecation"=>"http://very-deprecated.com",
        "name"=>"some-name",
        "profile"=>"some-profile",
        "title"=>"A Great Title",
        "hreflang"=>"en-US"}.each do |key, value|
          expect(link[key]).to eq(value)
        end
      end

    end

  end

end