# Representors

A library to simplify Hypermedia message representation. It has the knowledge of Hypermedia media-types from the Ancients!

This gem provides serializers and deserializers from/to known Hypermedia formats. It currently supports HAL and HALE.
It also provides a Representor class to hold the information from hypermedia responses, this class provides method to access properties, transitions, etc.


## Developing

Write your tests, write your code and make sure all tests pass:
```
bundle exec rspec
```

Also, you can check your test coverage by running mutant on the classes you have worked on.
For instance if you modified Representors::Representor, please execute:
```
MUTANT=true mutant --include lib --require representors --score 95 --use rspec Representors::Representor*
```

Reaching 100% mutant coverage is not feasible sometimes as they may be some false positives.
But please investigate any missing coverage, as it may indicate an actual problem with the tests.


## Copyright

Copyright &copy; 2016 Medidata Solutions Worldwide. See [LICENSE](LICENSE.md) for details.
