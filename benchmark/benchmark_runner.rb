#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'

require 'benchmark/ips'
require 'parslet'
require 'json'
require 'yaml'
require 'time'

# Load example parsers for benchmarking
require_relative '../example/calc'
require_relative '../example/json'

class BenchmarkRunner
  attr_reader :results

  def initialize
    @results = {
      metadata: {
        timestamp: Time.now.iso8601,
        ruby_version: RUBY_VERSION,
        ruby_platform: RUBY_PLATFORM,
        parslet_version: Parslet::VERSION,
        benchmark_ips_version: Benchmark::IPS::VERSION,
      },
      benchmarks: {},
    }
  end

  def self.run_all_and_export
    runner = new
    runner.run_all_benchmarks
    runner.export_results
    runner
  end

  def run_all_benchmarks
    puts 'Plurimath Parslet Performance Benchmarks'
    puts '=' * 50
    puts

    run_basic_parsing_benchmarks
    run_calculator_benchmarks
    run_json_benchmarks
    run_string_parsing_benchmarks
    run_repetition_benchmarks
    run_transform_benchmarks

    puts "\nBenchmark results exported to:"
    puts '- benchmark/results.json'
    puts '- benchmark/results.yaml'
  end

  def run_basic_parsing_benchmarks
    puts 'Basic Parsing Operations'
    puts '-' * 30

    # Simple string matching
    simple_parser = Class.new(Parslet::Parser) do
      root :simple
      rule(:simple) { str('hello') }
    end.new

    # Character class matching
    char_parser = Class.new(Parslet::Parser) do
      root :chars
      rule(:chars) { match('[a-z]').repeat(1) }
    end.new

    # Regex-like matching
    regex_parser = Class.new(Parslet::Parser) do
      root :pattern
      rule(:pattern) do
        match('\w').repeat(1) >> str('@') >> match('\w').repeat(1) >> str('.') >> match('\w').repeat(2, 4)
      end
    end.new

    benchmark_results = {}

    job = Benchmark.ips do |x|
      x.config(time: 5, warmup: 2)

      x.report("str('hello')") do
        simple_parser.parse('hello')
      end

      x.report("match('[a-z]').repeat(1)") do
        char_parser.parse('abcdefghijklmnop')
      end

      x.report('email-like pattern') do
        regex_parser.parse('user@example.com')
      end

      x.compare!
    end

    # Capture results after the benchmark completes
    job.entries.each do |entry|
      benchmark_results[entry.label] = {
        iterations_per_second: entry.stats.central_tendency,
        standard_deviation: entry.stats.error_percentage,
        microseconds_per_iteration: 1_000_000.0 / entry.stats.central_tendency,
      }
    end

    @results[:benchmarks][:basic_parsing] = {
      description: 'Basic parsing operations including string matching and character classes',
      results: benchmark_results,
    }

    puts
  end

  def run_calculator_benchmarks
    puts 'Calculator Parser Benchmarks'
    puts '-' * 30

    calc_parser = CalcParser.new

    simple_expr = '1+2'
    medium_expr = '1+2*3-4/2'
    complex_expr = '123*456+789-321/3*2+1'

    benchmark_results = {}

    job = Benchmark.ips do |x|
      x.config(time: 5, warmup: 2)

      x.report("parse simple: '#{simple_expr}'") do
        calc_parser.parse(simple_expr)
      end

      x.report("parse medium: '#{medium_expr}'") do
        calc_parser.parse(medium_expr)
      end

      x.report("parse complex: '#{complex_expr}'") do
        calc_parser.parse(complex_expr)
      end

      x.report('full calc simple') do
        calculate(simple_expr)
      end

      x.report('full calc complex') do
        calculate(complex_expr)
      end

      x.compare!
    end

    # Capture results after the benchmark completes
    job.entries.each do |entry|
      benchmark_results[entry.label] = {
        iterations_per_second: entry.stats.central_tendency,
        standard_deviation: entry.stats.error_percentage,
        microseconds_per_iteration: 1_000_000.0 / entry.stats.central_tendency,
      }
    end

    @results[:benchmarks][:calculator] = {
      description: 'Calculator parser benchmarks with expressions of varying complexity',
      test_expressions: {
        simple: simple_expr,
        medium: medium_expr,
        complex: complex_expr,
      },
      results: benchmark_results,
    }

    puts
  end

  def run_json_benchmarks
    puts 'JSON Parser Benchmarks'
    puts '-' * 30

    json_parser = MyJson::Parser.new
    json_transformer = MyJson::Transformer.new

    test_cases = {
      'simple JSON' => '{"key": "value"}',
      'array JSON' => '[1, 2, 3, 4, 5]',
      'complex JSON' => '{"users": [{"name": "John", "age": 30}, {"name": "Jane", "age": 25}], "count": 2}',
    }

    benchmark_results = {}

    job = Benchmark.ips do |x|
      x.config(time: 5, warmup: 2)

      test_cases.each do |name, json_string|
        x.report("parse #{name}") do
          json_parser.parse(json_string)
        end
      end

      # Test transformation separately
      simple_tree = json_parser.parse(test_cases['simple JSON'])
      x.report('transform simple JSON') do
        json_transformer.apply(simple_tree)
      end

      x.compare!
    end

    # Capture results after the benchmark completes
    job.entries.each do |entry|
      benchmark_results[entry.label] = {
        iterations_per_second: entry.stats.central_tendency,
        standard_deviation: entry.stats.error_percentage,
        microseconds_per_iteration: 1_000_000.0 / entry.stats.central_tendency,
      }
    end

    @results[:benchmarks][:json] = {
      description: 'JSON parser benchmarks with different document structures',
      test_cases: test_cases,
      results: benchmark_results,
    }

    puts
  end

  def run_string_parsing_benchmarks
    puts 'String Parsing Benchmarks'
    puts '-' * 30

    # Different string parsing approaches
    quoted_string_parser = Class.new(Parslet::Parser) do
      root :quoted_string
      rule(:quoted_string) { str('"') >> (str('"').absent? >> any).repeat.as(:content) >> str('"') }
    end.new

    escaped_string_parser = Class.new(Parslet::Parser) do
      root :escaped_string
      rule(:escaped_string) do
        str('"') >> (
          str('\\') >> any |
          str('"').absent? >> any
        ).repeat.as(:content) >> str('"')
      end
    end.new

    test_cases = {
      'simple quoted string' => '"hello world"',
      'long quoted string' => '"' + 'a' * 1000 + '"',
      'escaped string' => '"hello \\"world\\" with escapes"',
    }

    benchmark_results = {}

    job = Benchmark.ips do |x|
      x.config(time: 5, warmup: 2)

      x.report('simple quoted string') do
        quoted_string_parser.parse(test_cases['simple quoted string'])
      end

      x.report('long quoted string') do
        quoted_string_parser.parse(test_cases['long quoted string'])
      end

      x.report('escaped string') do
        escaped_string_parser.parse(test_cases['escaped string'])
      end

      x.compare!
    end

    # Capture results after the benchmark completes
    job.entries.each do |entry|
      benchmark_results[entry.label] = {
        iterations_per_second: entry.stats.central_tendency,
        standard_deviation: entry.stats.error_percentage,
        microseconds_per_iteration: 1_000_000.0 / entry.stats.central_tendency,
      }
    end

    @results[:benchmarks][:string_parsing] = {
      description: 'String parsing benchmarks with different string types and lengths',
      test_cases: test_cases.transform_values { |v| v.length > 50 ? "#{v[0..47]}..." : v },
      results: benchmark_results,
    }

    puts
  end

  def run_repetition_benchmarks
    puts 'Repetition Benchmarks'
    puts '-' * 30

    # Different repetition patterns
    simple_repeat_parser = Class.new(Parslet::Parser) do
      root :digits
      rule(:digits) { match('[0-9]').repeat(1) }
    end.new

    bounded_repeat_parser = Class.new(Parslet::Parser) do
      root :bounded
      rule(:bounded) { match('[0-9]').repeat(3, 6) }
    end.new

    maybe_repeat_parser = Class.new(Parslet::Parser) do
      root :maybe_digits
      rule(:maybe_digits) { match('[0-9]').repeat }
    end.new

    test_cases = {
      'repeat(1) short' => '123',
      'repeat(1) medium' => '123456789',
      'repeat(1) long' => '1' * 1000,
      'repeat(3,6) valid' => '12345',
      'repeat maybe' => '123456789',
    }

    benchmark_results = {}

    job = Benchmark.ips do |x|
      x.config(time: 5, warmup: 2)

      x.report('repeat(1) short') do
        simple_repeat_parser.parse(test_cases['repeat(1) short'])
      end

      x.report('repeat(1) medium') do
        simple_repeat_parser.parse(test_cases['repeat(1) medium'])
      end

      x.report('repeat(1) long') do
        simple_repeat_parser.parse(test_cases['repeat(1) long'])
      end

      x.report('repeat(3,6) valid') do
        bounded_repeat_parser.parse(test_cases['repeat(3,6) valid'])
      end

      x.report('repeat maybe') do
        maybe_repeat_parser.parse(test_cases['repeat maybe'])
      end

      x.compare!
    end

    # Capture results after the benchmark completes
    job.entries.each do |entry|
      benchmark_results[entry.label] = {
        iterations_per_second: entry.stats.central_tendency,
        standard_deviation: entry.stats.error_percentage,
        microseconds_per_iteration: 1_000_000.0 / entry.stats.central_tendency,
      }
    end

    @results[:benchmarks][:repetition] = {
      description: 'Repetition pattern benchmarks with different strategies and input lengths',
      test_cases: test_cases.transform_values { |v| v.length > 20 ? "#{v[0..17]}..." : v },
      results: benchmark_results,
    }

    puts
  end

  def run_transform_benchmarks
    puts 'Transform Benchmarks'
    puts '-' * 30

    # Simple transform
    simple_transform = Class.new(Parslet::Transform) do
      rule(number: simple(:n)) { Integer(n) }
      rule(word: simple(:w)) { w.to_s.upcase }
    end.new

    # Complex transform with multiple rules
    complex_transform = Class.new(Parslet::Transform) do
      rule(number: simple(:n)) { { type: :number, value: Integer(n) } }
      rule(word: simple(:w)) { { type: :word, value: w.to_s.upcase } }
      rule(list: subtree(:items)) { { type: :list, items: items } }
      rule(pair: { key: simple(:k), value: simple(:v) }) { { k.to_s => v } }
    end.new

    test_cases = {
      simple: { number: '123' },
      medium: [{ number: '123' }, { word: 'hello' }, { number: '456' }],
      complex: {
        list: [
          { pair: { key: 'name', value: { word: 'john' } } },
          { pair: { key: 'age', value: { number: '30' } } },
        ],
      },
    }

    benchmark_results = {}

    job = Benchmark.ips do |x|
      x.config(time: 5, warmup: 2)

      x.report('simple transform') do
        simple_transform.apply(test_cases[:simple])
      end

      x.report('medium transform') do
        simple_transform.apply(test_cases[:medium])
      end

      x.report('complex transform') do
        complex_transform.apply(test_cases[:complex])
      end

      x.compare!
    end

    # Capture results after the benchmark completes
    job.entries.each do |entry|
      benchmark_results[entry.label] = {
        iterations_per_second: entry.stats.central_tendency,
        standard_deviation: entry.stats.error_percentage,
        microseconds_per_iteration: 1_000_000.0 / entry.stats.central_tendency,
      }
    end

    @results[:benchmarks][:transform] = {
      description: 'AST transformation benchmarks with different complexity levels',
      test_cases: test_cases.transform_values(&:to_s),
      results: benchmark_results,
    }

    puts
  end

  def export_results
    # Export to JSON
    File.write('benchmark/results.json', JSON.pretty_generate(@results))

    # Export to YAML
    File.write('benchmark/results.yaml', @results.to_yaml)

    # Create a summary report
    create_summary_report
  end

  private

  def create_summary_report
    summary = {
      metadata: @results[:metadata],
      summary: {
        total_benchmarks: @results[:benchmarks].values.sum { |cat| cat[:results].size },
        categories: @results[:benchmarks].keys,
        fastest_operation: find_fastest_operation,
        slowest_operation: find_slowest_operation,
        performance_insights: generate_insights,
      },
    }

    File.write('benchmark/summary.json', JSON.pretty_generate(summary))
    File.write('benchmark/summary.yaml', summary.to_yaml)
  end

  def find_fastest_operation
    fastest = nil
    fastest_ips = 0

    @results[:benchmarks].each do |category, data|
      data[:results].each do |name, result|
        if result[:iterations_per_second] > fastest_ips
          fastest_ips = result[:iterations_per_second]
          fastest = { category: category, operation: name, ips: fastest_ips }
        end
      end
    end

    fastest
  end

  def find_slowest_operation
    slowest = nil
    slowest_ips = Float::INFINITY

    @results[:benchmarks].each do |category, data|
      data[:results].each do |name, result|
        if result[:iterations_per_second] < slowest_ips
          slowest_ips = result[:iterations_per_second]
          slowest = { category: category, operation: name, ips: slowest_ips }
        end
      end
    end

    slowest
  end

  def generate_insights
    insights = []

    # Find categories with highest variance
    @results[:benchmarks].each do |category, data|
      ips_values = data[:results].values.map { |r| r[:iterations_per_second] }
      next unless ips_values.size > 1

      max_ips = ips_values.max
      min_ips = ips_values.min
      ratio = max_ips / min_ips
      if ratio > 10
        insights << "#{category.to_s.humanize} shows high performance variance (#{ratio.round(1)}x difference)"
      end
    end

    insights
  end
end

# Add humanize method for category names
class String
  def humanize
    to_s.gsub('_', ' ').split.map(&:capitalize).join(' ')
  end
end

BenchmarkRunner.run_all_and_export if __FILE__ == $0
