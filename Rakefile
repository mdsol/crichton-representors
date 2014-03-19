lib_dir = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib_dir)
$LOAD_PATH.uniq!

require 'rubygems'
require 'bundler/setup'
require 'rake'

Dir['tasks/**/*.rake'].each { |rake| load rake }
