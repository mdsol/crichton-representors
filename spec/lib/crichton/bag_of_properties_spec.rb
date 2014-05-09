require 'spec_helper'

describe Crichton::BagOfProperties do
  subject(:bag) {Crichton::BagOfProperties.new({count: 1})}
  describe '[]' do
    it 'returns a key value if in the object' do
      expect(bag[:count]).to eq(1)
    end
    it 'returns nil if not in the object' do
      expect(bag[:not_in_object]).to be_nil
    end
  end

  describe 'any method' do
    it 'returns the value for that method if key in object' do
      expect(bag.count).to eq(1)
    end
    it 'raises an error for that method if the key not in object' do
      expect{bag.not_in_object}.to raise_error(NoMethodError)
    end
  end
end