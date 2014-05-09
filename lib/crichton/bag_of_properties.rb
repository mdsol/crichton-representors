module Crichton
  # This class is supposed to stay small and simple.
  # This class is a Hash which can be accessed either by the [] method
  # or by calling methods with the names of the keys directly
  # cool = BagOfProperties.new({a:1})
  # cool[:a] == cool.a
  class BagOfProperties < Hash
    def initialize(hash={})
      self.merge!(hash)
    end

    def method_missing(method, *args, &block)
      if self.has_key?(method.to_s)
        self[method.to_s]
      else
        super
      end
    end
  end
end
