require 'open-uri'
require 'json'


def convert_to_representor(index, example)
  representor = Representors::HaleDeserializer.new(example).to_representor
  serialized_representor = Representors::Serialization::HaleSerializer.new(representor).to_media_type
  if JSON.parse(serialized_representor) != JSON.parse(example)
    puts example
    puts "Example number #{index} can not be roundtriped!"
  else
    puts "Example number #{index} was roundtriped, HOORAY!"
  end

rescue JSON::ParserError
  puts example
  puts "Example number #{index} has a JSON error!"
rescue TypeError => e
  puts example
  puts "Example number #{index} breaks our code!"
  puts e
end

#TODO: Test Hal spec also
desc "Rake tast to test the implementation against the specs"
task :test_specs do

  hale_spec = ''
  hale_spec << open('https://raw.githubusercontent.com/mdsol/hale/master/README.md').read

  examples = hale_spec.scan(/```json(.*?)```/m).flatten

  examples.each_with_index do |example, index|
    convert_to_representor(index+1, example)
  end

end
