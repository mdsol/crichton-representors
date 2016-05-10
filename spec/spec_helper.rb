unless ENV['MUTANT']
  require 'simplecov'
  SimpleCov.start
end

SPEC_DIR = File.expand_path("..", __FILE__)
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'representors'

Dir["#{SPEC_DIR}/support/*.rb"].each { |f| require f }

def create_serializer(name)
  Class.new(Representors::SerializerBase) do |klass|
    klass.media_symbol name.to_sym
    klass.media_type name
  end
end

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random' unless ENV['RANDOMIZE'] == 'false'

  config.include Support::Helpers
  config.include RepresentorSupport::Utilities
end
