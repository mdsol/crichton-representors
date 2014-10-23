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
    DEFAULT_HASH_VALUES = {
      id: nil,
      doc: nil,
      href: nil,
      protocol: nil,
      attributes: {},
      links: [],
      transitions: [],
      embedded: {}
    }.each_value(&:freeze).freeze


    # be able to create from a hash
    def initialize(hash = {})
      DEFAULT_HASH_VALUES.each { |k, v| self[k] = hash[k] || (v.is_a?(Enumerable) ? v.dup : v) }
    end

    # Be able to generate a new structure with myself and a hash
    def merge(hash)
      new_representor_hash = RepresentorHash.new(to_h)
      hash.each_pair { |k, v| new_representor_hash[k] = v }
      new_representor_hash
    end

    # to_h does not exists in Ruby < 2.0
    def to_h
      members.each_with_object({}) { |member, hash| hash[member] = self[member] }
    end
  end
end
