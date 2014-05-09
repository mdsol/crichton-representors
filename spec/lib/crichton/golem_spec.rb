require 'spec_helper'


describe Crichton::Golem do
  subject(:golem) {Crichton::Golem.new}
  describe '#initialize' do
    it 'creates an empty list of properties' do
      expect(golem.properties).to be_empty
    end
    it 'creates an empty list of links' do
      expect(golem.links).to be_empty
    end
    it 'creates an empty list of embedded resources' do
      expect(golem.embedded_resources).to be_empty
    end
    it 'raises an error if a key not in the properties is called' do
      expect{golem.not_in_object}.to raise_error(NoMethodError)
    end

  end

  describe '#create_property' do
    it 'creates a property accessible via properties ' do
      golem.create_property('sand', 'worm')
      expect(golem.properties).to eq({'sand' => 'worm'})
    end
    it 'creates a property accessible via any method in the object' do
      golem.create_property('sand', 'worm')
      expect(golem.sand).to eq('worm')
    end
  end

  describe '#create_link' do
    let(:link_name) {'next'}
    let(:link_values) { { 'href' => 'http://something.com', 'title' => 'the next big thing'}}

    it 'creates a link accessible via links[]' do
      golem.create_link(link_name, link_values)
      expect(golem.links[link_name]).to eq(link_values)
    end

    it 'creates a link accesible via a method' do
      golem.create_link(link_name, link_values)
      expect(golem.links.next).to eq(link_values)
    end
  end

end
