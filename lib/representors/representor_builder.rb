require 'representors/representor_hash'
module Representors

  ##
  # Builder has methods to abstract the construction of Representor objects
  # In the present implementation it will create a hash of a specific format to
  # Initialize the Representor with, this will create classess with it.
  class RepresentorBuilder
    HREF_KEY = 'href'
    DATA_KEY = 'data'

    def initialize(representor_hash = {})
      @representor_hash = RepresentorHash.new(representor_hash)
    end

    # Returns a hash usable by the representor class
    def to_representor_hash
      @representor_hash
    end

    # Adds an attribute to the Representor. We are creating a hash where the keys are the
    # names of the attributes
    def add_attribute(name, value, options={})
      @representor_hash.attributes[name] = options.merge({value: value})
    end

    # Adds a transition to the Representor, each transition is a hash of values
    # The transition collection is an Array
    def add_transition(rel, href, options={})
      link_values = options.merge({href: href, rel: rel})
      if options[DATA_KEY]
        link_values[Transition::DESCRIPTORS_KEY] = link_values.delete(DATA_KEY)
      end
      @representor_hash.transitions.push(link_values)
    end

    # Adds directly an array to our array of transitions
    def add_transition_array(rel, array_of_hashes)
      @representor_hash.transitions += array_of_hashes.map do |link_values|
        link_values[:rel] = rel
        link_values[:href] = link_values.delete(HREF_KEY)
        if link_values[DATA_KEY]
          link_values[Transition::DESCRIPTORS_KEY] = link_values.delete(DATA_KEY)
        end
        link_values
      end
    end

    def add_embedded(name, embedded_resource)
      @representor_hash.embedded[name] = embedded_resource
    end

  end
end
