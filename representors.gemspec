$LOAD_PATH.unshift('lib')
require 'representors/version'

Gem::Specification.new do |s|
  s.name          = 'representors'
  s.version       = Representors::VERSION
  s.license       = 'MIT'
  s.date          = Time.now.strftime('%Y-%m-%d')
  s.summary       = 'It has the knowledge of Hypermedia media-types from the Ancients!'
  s.homepage      = 'https://github.com/mdsol/representors'
  s.email         = ''
  s.authors       = ['Mark W. Foster', 'Shea Valentine']
  s.files         = ['lib/**/*', 'spec/**/*', 'tasks/**/*', '[A-Z]*'].map { |glob| Dir[glob] }.inject([], &:+)
  s.require_paths = ['lib']
  s.rdoc_options  = ['--main', 'README.md']

  s.description = <<-DESC
    Crichton Representors is a library containing serializers and deserializers to and from hypermedia formats.
    This library does not have the functionality to get and post data over the Internet. Consider Farscape for that.
    This library also does not automatically decorates objects. Consider Crichton for that.
  DESC

  s.add_dependency 'rake'
  s.add_dependency 'addressable', '~> 2.3'

  s.add_development_dependency 'byebug'
  s.add_development_dependency 'mutant-rspec', '~> 0.8'
  s.add_development_dependency 'redcarpet', '~> 3.3'
  s.add_development_dependency 'rspec', '~> 3.4'
  s.add_development_dependency 'simplecov', '~> 0.11'
  s.add_development_dependency 'yard', '>= 0.9.11', '~> 0.9'
end
