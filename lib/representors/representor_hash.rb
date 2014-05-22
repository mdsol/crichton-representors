module Representors
  # This is the structure shared between the builder and the representor.
  # Encapsulate the name of the keys constants
  # TODO: create documentation with this:
  #  https://gist.github.com/sheavalentine-mdsol/69649d4e1aeee76de21c
  # TODO: Convert to Struct
  RepresentorHash  = Struct.new(:id, :doc, :href, :protocol, :attributes, :embedded, :links, :transitions) do
    def initialize(hash={})
      hash.each_pair do |key, value|
        self[key] = value
      end
      #debugger
      #self[*hash.values_at(*RepresentorHash.members.map {|m| m.to_sym})]
    end
    def merge(hash)
      new_representor_hash = RepresentorHash.new(to_h)
      hash.each_pair do |key, value|
        new_representor_hash[key] = value
      end
      new_representor_hash
    end
  end

end
