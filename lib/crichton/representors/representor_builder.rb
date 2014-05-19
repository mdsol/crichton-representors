module Crichton
  module Representors

    ##
    # Builder has methods to abstract the construction of Representor objects
    # In the present implementation it will create a hash of a specific format to
    # Initialize the Representor with, this will create classess with it.
    class RepresentorBuilder

      def initialize
        @attributes = {}
        @transitions = []
        @embedded_resources = {}
      end

      # Returns a hash usable by the representor class
      def to_representor_hash
        representor_hash = RepresentorHash.new
        if !@attributes.empty?
          representor_hash.attributes= @attributes
        end
        if !@transitions.empty?
          representor_hash.transitions = @transitions
        end
        if !@embedded_resources.empty?
          representor_hash.embedded = @embedded_resources
        end
        representor_hash
      end

      # Adds an attribute to the Representor. We are creating a hash where the keys are the
      # names of the attributes
      def add_attribute(name, value, options=nil)
        options ||= {}
        @attributes[name] = options.merge({value: value})
      end

      # Adds a transition to the Representor, each transition is a hash of values
      # The transition collection is an Array
      def add_transition(rel, href, options=nil)
        options ||= {}
        link_values = options.merge({href: href, rel: rel})
        @transitions.push(link_values)
      end

      # Adds directly an array to our array of transitions
      def add_transition_array(rel, array_of_hashes)
        @transitions += array_of_hashes.map do |link_values|
          link_values[:rel] = rel
          link_values[:href] = link_values.delete('href')
          link_values
        end
      end

      def add_embedded(name, embedded_resource)
        @embedded_resources[name] = embedded_resource
      end

    end
  end
end
