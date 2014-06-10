module Representors
  # This is the structure shared between the builder and the representor.
  # This class allows to pass all the data to the representor without polluting it with methods
  # It is supposed to be a fast class (Struct is implemented in C)
  # The structure looks like this:
  # id: [string]
  # doc: [string]
  # href: [string]
  # protocol: [string]
  # attributes: [hash]  { key => value }
  # links: [array of hashes]
  # transitions: [array of hashes]
  # embedded: [hash] where each value can be recursively defined by this same structure
  RepresentorHash  = Struct.new(:id, :doc, :href, :protocol, :attributes, :embedded, :links, :transitions) do

    # be able to create from a hash
    def initialize(hash = {})
      hash ||= {}
      hash.each_pair do |key, value|
        self[key] = value
      end
    end

    # Be able to generate a new structure with myself and a hash
    def merge(hash)
      new_representor_hash = RepresentorHash.new(to_h)
      hash.each_pair do |key, value|
        new_representor_hash[key] = value
      end
      new_representor_hash
    end

    # to_h does not exists in Ruby < 2.0
    if RUBY_VERSION < '2.0'
      def to_h
        members.each_with_object({}) { |member, hash| hash[member] = self[member] if self[member] }
      end
    end

  end

end
