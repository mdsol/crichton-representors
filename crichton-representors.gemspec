$LOAD_PATH.unshift('lib')
require 'crichton/representors/version'

Gem::Specification.new do |s|
  s.name = 'crichton-representors'
  s.version = Crichton::Representor::VERSION::STRING
  s.date = Time.now.strftime('%Y-%m-%d')
  s.summary = 'It has the knowledge of Hypermedia media-types from the Ancients!'
  s.homepage = 'http://github.com//crichton-representors'
  s.email = ''
  s.authors = ['Mark W. Foster', 'Shea Valentine']
  s.files = ['lib/**/*', 'spec/**/*', 'tasks/**/*', '[A-Z]*'].map { |glob| Dir[glob] }.inject([], &:+)
  s.require_paths = ['lib']
  s.rdoc_options = ['--main', 'README.md']

  s.description = <<-DESC
    Crichton Representors is a library to simplify Hypermedia message representation.
  DESC
  
  s.add_dependency('enumerable-lazy', '~> 0.0.1') if RUBY_VERSION < '2.0'
  s.add_dependency('rake')
end
