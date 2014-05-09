require 'spec_helper'
require 'yaml'
require 'uri'

module Crichton
  describe Field do
    before do
      @field_hash = {
        total_count: {
          doc: 'The total count of DRDs.',
          type: 'semantic',
          profile: 'http://alps.io/schema.org/Integer',
          sample: 1,
          value: 2
        },
      }
    end
    
    let(:field_hash) { @field_hash }
    let(:subject) { Field.new(field_hash) }  
    
    describe '.new' do
      it 'returns a Crichton::Field instance' do
        subject.should be_an_instance_of(Crichton::Field)
      end
    
      describe '#to_hash' do
        it 'returns its constructor hash' do
          subject.to_hash.should == field_hash
        end
      end
    
      describe '#name' do
        it 'returns the key when requesting the name' do
          subject.name.should == field_hash.keys.first
        end
      end
      
      %w(value default description type data_type).map(&:to_sym).each do |key|
        describe "\##{key}" do
          it "it should return it's hash value" do
           subject.send(key).should == field_hash.first[1][key]
          end
        end
      end
      
      describe '#options' do
        it 'returns an options object' do
          @field_hash[:total_count][:options] = {}
          subject.options.should be_an_instance_of(Options)
        end
        
        it 'has a list interface even when a hash' do
          @field_hash[:total_count][:options] = {hash: {foo: 'bar', ninja: 'cow'}}
          subject.options.as_list.should == field_hash[:total_count][:options][:hash].keys
        end
        
        it 'has a hash interface even when a list' do
          @field_hash[:total_count][:options] = {list: ['bar', 'cow']}
          subject.options.as_hash.should == {bar: 'bar', cow: 'cow'}
        end
        
        it 'has a hash interface when external' do
          @field_hash[:total_count][:options] = {external: {source: 'foo', target: 'bar'}}
          subject.options.as_hash.should == {source: 'foo', target: 'bar'}
        end
        
        it 'defaults to a sensible id' do
           @field_hash[:total_count][:options] = {external: {source: 'foo', target: 'bar'}}
           subject.options.id.should == 'total_count_options'       
        end
        
        it 'gives back a passed in id' do
          @field_hash[:total_count][:options] = {list: ['bar', 'cow'], id: 'fortunes grace'}
          subject.options.id.should == 'fortunes grace'
        end
        
      end
      
      describe '#validators' do
        it 'returns a list of hashes whose key is equal to the validator type' do
          validators = [{ max_length: 8 }, :required]
          @field_hash[:total_count][:validators] = validators
          hash_keys = validators.map { |hs| hs.instance_of?(Symbol) ? hs : hs.keys.first }
          object_keys = subject.validators.map { |hash| hash.keys.first }
          object_keys.should == hash_keys
        end
        
        it 'returns a list of hashes whose value must be matched against' do
          validators = [{max_length: 8}, :required]
          @field_hash[:total_count][:validators] = validators
          hash_values = validators.map { |hs| hs.instance_of?(Symbol) ? hs : hs[hs.keys.first] }
          object_vals = subject.validators.map { |hash| hash[hash.keys[0]] }
          object_vals.should == hash_values
        end
      end

      describe '#call' do
        it 'returns the value when called' do
          subject.().should == @field_hash[:total_count][:value]
        end
      end
    end    
  end
end
