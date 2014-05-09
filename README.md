# Crichton Representors
[![Build Status](https://travis-ci.org/mdsol/crichton-representors.svg)](https://travis-ci.org/mdsol/crichton-representors)
[Crichton][] Representors is a library to simplify Hypermedia message representation. It has the knowledge of Hypermedia 
media-types from the Ancients!

NOTE: THIS IS UNDER HEAVY DEV AND IS NOT READY TO BE USED YET

Representors contains Deserializers for Hypermedia formats to a
convenience class which can be used independently of the format the code
is interacting with.

Currently the only format parsed is application/hal+json

## Usage

You can use a particular serializer directly to get an object:
```Ruby
my_house = Crichton::HalDeserializer.new(some_real_state_document).deserialize
```
Or you can ask provide the format and let representors choose the
serializer:
```Ruby
my_house = Crichton::Deserializer.create('application/hal+json, some_real_state_document).deserialize
```

now you can access properties
```Ruby
is_big = true if my_house.room_count > 4
```

access links
```Ruby
wget my_house.links.pay_rent.href
```

access embedded resources
```Ruby
wget my_house.embedded_resources.kitchen.links.put_out_fire
```

Alternatively and to access names that use 'properties, links and
embedded_resources' as hashes:
```Ruby
puts my_house.links['self'].title
```


## Contributing
See [CONTRIBUTING][] for details.

## Copyright
Copyright &copy; 2014 Medidata Solutions Worldwide. See [LICENSE][] for details.

[Crichton]: https://github.com/mdsol/crichton
[CONTRIBUTING]: https://github.com/mdsol/crichton/blob/develop/CONTRIBUTING.md
[Documentation]: http://rubydoc.info/github/mdsol/crichton-representors
[LICENSE]: LICENSE.md
