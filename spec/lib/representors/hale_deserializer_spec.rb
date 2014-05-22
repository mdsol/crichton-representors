require 'spec_helper'

module Representors

RSpec.describe HaleDeserializer do
  it 'inherits from HalDeserializer' do
    expect(HaleDeserializer.class.ancestors.include? HalDeserializer)
  end

  it 'provides the iana format application/vnd.hale+json' do
    expect(HaleDeserializer.iana_formats).to eq(['application/vnd.hale+json'])
  end

  it 'provides the symbol format :hale' do
    expect(HaleDeserializer.symbol_formats).to eq([:hale])
  end

end

end