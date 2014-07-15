require 'representors'
require 'benchmark'

ITERATIONS = 5
DESERIALIZATIONS = 10_000
HAL_BENCHMARK_FILE = 'complex_hal_document.json'
HALE_BENCHMARK_FILE = 'complex_hale_document.json'


def benchmark
  benchmark_result = Benchmark.bm do |benchmarker|
    1.upto(ITERATIONS) do |iteration|
      benchmarker.report("Iteration #{iteration}") do
        DESERIALIZATIONS.times do
          yield
        end
      end
    end
  end
  benchmark_result
  average_total_times = benchmark_result.map(&:total).inject(&:+) / ITERATIONS
  average_operation_ms = (average_total_times * 1000) / DESERIALIZATIONS

  puts "Processing #{DESERIALIZATIONS} objects took on average #{'%.4f' % average_total_times} seconds"
  puts "It took #{'%.4f' % average_operation_ms} milliseconds to process each document or representor"
end

def benchmark_deserializer(format, document)
  data = File.read( File.join(File.dirname(__FILE__), document))
  puts "Deserializing #{format}:"

  benchmark do
    result = Representors::DeserializerFactory.build(format, data).to_representor
    result.properties
    result.transitions
    result.embedded
  end
  puts "------------------"
  puts " "
end


def benchmark_serializer(format, document)
  data = File.read( File.join(File.dirname(__FILE__), document))
  representor = Representors::DeserializerFactory.build(format, data).to_representor

  puts "Serializing #{format}:"

  benchmark do
    Representors::SerializerFactory.build(format, representor).to_media_type
  end
  puts "------------------"
  puts " "
end

namespace :benchmark do
  desc 'Benchmark deserializations'
  task :deserializations do
    benchmark_deserializer('application/hal+json', HAL_BENCHMARK_FILE )
    benchmark_deserializer('application/vnd.hale+json', HALE_BENCHMARK_FILE )
  end

  desc 'Benchmark serializations'
  task :serializations do
    benchmark_serializer('application/hal+json', HAL_BENCHMARK_FILE )
    benchmark_serializer('application/vnd.hale+json', HALE_BENCHMARK_FILE )
  end

  desc 'runs all benchmarks'
  task :all do
    Rake::Task['benchmark:deserializations'].invoke
    Rake::Task['benchmark:serializations'].invoke
  end

end
