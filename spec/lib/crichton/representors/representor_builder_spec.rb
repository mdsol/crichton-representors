require 'spec_helper'


RSpec.shared_examples_for 'one attribute added' do
  it 'creates a semantic key at the top level of the output' do
    expect(builder.to_representor_hash.has_key?(Crichton::Representors::RepresentorHash::SEMANTICS_KEY)).to be_true
  end

  it 'adds the attribute name as a key under "semantic" in the output hash' do
    expect(semantic_field.has_key?(attribute_name)).to be_true
  end

  it 'adds the value under "value" in a hash which key is the attribute name' do
    expect(semantic_field[attribute_name][:value]).to eq(attribute_value)
  end

  it 'when called twice the value is overwritten' do
    new_value = 'new_value'
    builder.add_attribute(attribute_name, new_value)
    expect(semantic_field[attribute_name]).to eq({value: new_value})
  end
end


RSpec.shared_examples_for 'one transition added' do
  it 'creates a transition key at the top level of the output' do
    expect(builder.to_representor_hash.has_key?(Crichton::Representors::RepresentorHash::TRANSITIONS_KEY)).to be_true
  end

  it 'adds an array under "transitions" ' do
    expect(transitions_field).to be_instance_of(Array)
  end

  it 'the members of the transitions has a href' do
    expect(transitions_field.first[:href]).to eq(transition_href)
  end
  it 'the members of the transitions has a rel' do
    expect(transitions_field.first[:rel]).to eq(transition_name)
  end
end

RSpec.shared_examples_for 'one embedded added' do
  it 'creates a transition key at the top level of the output' do
    expect(builder.to_representor_hash.has_key?(Crichton::Representors::RepresentorHash::EMBEDDED_KEY)).to be_true
  end

  it 'adds a hash under "embedded" ' do
    expect(embedded_field).to be_instance_of(Hash)
  end

  it 'creates an embedded resource inside its own hash' do
    expect(embedded_field[embedded_name]).to eq(embedded_value)
  end

end


RSpec.describe Crichton::Representors::RepresentorBuilder do
  subject(:builder) {Crichton::Representors::RepresentorBuilder.new}
  let(:semantic_field) {builder.to_representor_hash.attributes}
  let(:transitions_field) {builder.to_representor_hash.transitions}
  let(:embedded_field) {builder.to_representor_hash.embedded}

  context 'empty builder' do
    it "returns an empty hash" do
      expect(builder.to_representor_hash).to eq({})
    end
  end

  describe '#add_attribute' do
    let(:attribute_name) {'some_name'}
    let(:attribute_value) {'cool_value'}

    context 'Added an attribute without extra options' do
      before do
        builder.add_attribute(attribute_name, attribute_value)
      end

      it_behaves_like 'one attribute added'
    end

    context 'Added an attribute with nil extra options' do
      before do
        builder.add_attribute(attribute_name, attribute_value, nil)
      end

      it_behaves_like 'one attribute added'
    end

    context 'Added an attribute with empty extra options' do
      before do
        builder.add_attribute(attribute_name, attribute_value, {})
      end

      it_behaves_like 'one attribute added'
    end

    context 'Added an attribute with extra options' do
      let(:extra_key) {'doc'}
      let(:extra_value) {'Some documentation'}
      let(:extra_options) { {extra_key => extra_value} }

      before do
        builder.add_attribute(attribute_name, attribute_value, extra_options)
      end

      it_behaves_like 'one attribute added'

      it 'adds any extra options as keys under the attribute name hash' do
        expect(semantic_field[attribute_name].has_key?(extra_key)).to be_true
      end

      it 'adds the correct value for the extra options' do
        expect(semantic_field[attribute_name][extra_key]).to eq(extra_value)
      end
    end

  end

  describe '#add_transition' do
    let(:transition_name) {'trusmis'}
    let(:transition_href) {'/path_to_there'}

    context 'Added a transition without extra options' do
      before do
        builder.add_transition(transition_name, transition_href)
      end

      it_behaves_like 'one transition added'
    end

    context 'Added a transition with extra options' do
      let(:extra_key) {'doc'}
      let(:extra_value) {'Some documentation'}
      let(:extra_options) { {extra_key => extra_value} }

      before do
        builder.add_transition(transition_name, transition_href, extra_options)
      end

      it_behaves_like 'one transition added'

      it 'adds any extra options as keys under the attribute name hash' do
        expect(transitions_field.first.has_key?(extra_key)).to be_true
      end

      it 'adds the correct value for the extra options' do
        expect(transitions_field.first[extra_key]).to eq(extra_value)
      end
    end
  end

  describe '#add_transition_array' do
    let(:transition_name) {'mumismo'}
    let(:transition_href) {'/path_to_there'}
    let(:transition_array) { [{hello: 'world', 'href' => transition_href}, {count: 10}]}

    before do
      builder.add_transition_array(transition_name, transition_array)
    end

    it 'creates two elements under transitions' do
      expect(transitions_field).to have(2).items
    end

    it_behaves_like 'one transition added'
  end


  describe '#add_embedded' do
    let(:embedded_name) {'trusmis'}
    let(:embedded_value) {  { 'data' => 'here'}}

    context 'Added an embedded' do
      before do
        builder.add_embedded(embedded_name, embedded_value)
      end

      it_behaves_like 'one embedded added'
    end
  end


end
