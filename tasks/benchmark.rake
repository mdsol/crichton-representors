require 'representors'
require 'benchmark'

ITERATIONS = 5
DESERIALIZATIONS = 10_000

def benchmark_deserializer(format, document)
  data = File.read( File.join(File.dirname(__FILE__), document))

  benchmark_result = Benchmark.bm do |benchmarker|
    1.upto(ITERATIONS) do |iteration|
      benchmarker.report("Iteration #{iteration}") do
        DESERIALIZATIONS.times do
          result = Representors::Deserializer.build(format, data).to_representor
          result.properties
          result.transitions
          result.embedded
        end
      end
    end
  end
  benchmark_result
end

namespace :benchmark do
  desc 'Benchmark deserializations'
  task 'deserializations' do
    benchmark_result = benchmark_deserializer('application/hal+json', 'complex_hal_document.json')
    average_total_times = benchmark_result.map(&:total).inject(&:+) / ITERATIONS
    average_operation_ms = (average_total_times * 1000) / DESERIALIZATIONS

    puts "Deserializing #{DESERIALIZATIONS} complex documents took on average #{'%.4f' % average_total_times} seconds"
    puts "It took #{'%.4f' % average_operation_ms} milliseconds to deserialize each document"
  end
end
