$LOAD_PATH.unshift('lib')
require 'representors/version'

Gem::Specification.new do |s|
  s.name = 'representors'
  s.version = Representors::VERSION
  s.date = Time.now.strftime('%Y-%m-%d')
  s.summary = 'It has the knowledge of Hypermedia media-types from the Ancients!'
  s.homepage = 'http://github.com/representors'
  s.email = ''
  s.authors = ['Mark W. Foster', 'Shea Valentine']
  s.files = ['lib/**/*', 'spec/**/*', 'tasks/**/*', '[A-Z]*'].map { |glob| Dir[glob] }.inject([], &:+)
  s.require_paths = ['lib']
  s.rdoc_options = ['--main', 'README.md']

  s.description = <<-DESC
    Crichton Representors is a library containing serializers and deserializers to and from hypermedia formats.
    This library does not have the functionality to get and post data over the Internet. Consider Farscape for that.
    This library also does not automatically decorates objects. Consider Crichton for that.
  DESC

  s.add_dependency('enumerable-lazy', '~> 0.0.1') if RUBY_VERSION < '2.0'
  s.add_dependency('rake')
end
