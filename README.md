# Representors
[Crichton][] Representors is a library to simplify Hypermedia message representation. It has the knowledge of Hypermedia
media-types from the Ancients!

The representors gem provides serializers and deserializers from/to known Hypermedia formats. It supports HAL and HALE.
It also provides a Representor class to hold the information from hypermedia responses, this class provides method to access properties, transitions, etc.

## Developing

Write your tests, write your code and make sure all tests pass:
```
bundle exec rspec
```

Also make sure you wrote good test by running mutant on the classes you have woked on.
For instance if you modified Representors::Representor, please execute:
```
MUTANT=true mutant --include lib --require representors --use rspec Representors::Representor*
```

And make sure you get a 100% coverage.


## Copyright
Copyright &copy; 2014 Medidata Solutions Worldwide. See [LICENSE][] for details.

[Crichton]: https://github.com/mdsol/crichton
[LICENSE]: LICENSE.md
