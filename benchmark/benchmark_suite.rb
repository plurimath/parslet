#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'

require 'benchmark/ips'
require 'parslet'
require 'json'
require 'yaml'

# Load example parsers for benchmarking
require_relative '../example/calc'
require_relative '../example/json'

class BenchmarkSuite
  def self.run_all
    puts 'Plurimath Parslet Performance Benchmarks'
    puts '=' * 50
    puts

    new.run_basic_parsing_benchmarks
    new.run_calculator_benchmarks
    new.run_json_benchmarks
    new.run_string_parsing_benchmarks
    new.run_repetition_benchmarks
    new.run_transform_benchmarks
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

    Benchmark.ips do |x|
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
    puts
  end

  def run_calculator_benchmarks
    puts 'Calculator Parser Benchmarks'
    puts '-' * 30

    calc_parser = CalcParser.new
    calc_transform = CalcTransform.new

    simple_expr = '1+2'
    medium_expr = '1+2*3-4/2'
    complex_expr = '123*456+789-321/3*2+1'

    Benchmark.ips do |x|
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
    puts
  end

  def run_json_benchmarks
    puts 'JSON Parser Benchmarks'
    puts '-' * 30

    json_parser = MyJson::Parser.new
    json_transformer = MyJson::Transformer.new

    simple_json = '{"key": "value"}'
    array_json = '[1, 2, 3, 4, 5]'
    complex_json = '{"users": [{"name": "John", "age": 30}, {"name": "Jane", "age": 25}], "count": 2}'

    Benchmark.ips do |x|
      x.config(time: 5, warmup: 2)

      x.report('parse simple JSON') do
        json_parser.parse(simple_json)
      end

      x.report('parse array JSON') do
        json_parser.parse(array_json)
      end

      x.report('parse complex JSON') do
        json_parser.parse(complex_json)
      end

      # Test transformation separately
      simple_tree = json_parser.parse(simple_json)
      x.report('transform simple JSON') do
        json_transformer.apply(simple_tree)
      end

      x.compare!
    end
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

    simple_string = '"hello world"'
    long_string = '"' + 'a' * 1000 + '"'
    escaped_string = '"hello \\"world\\" with escapes"'

    Benchmark.ips do |x|
      x.config(time: 5, warmup: 2)

      x.report('simple quoted string') do
        quoted_string_parser.parse(simple_string)
      end

      x.report('long quoted string') do
        quoted_string_parser.parse(long_string)
      end

      x.report('escaped string') do
        escaped_string_parser.parse(escaped_string)
      end

      x.compare!
    end
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

    short_digits = '123'
    medium_digits = '123456789'
    long_digits = '1' * 1000

    Benchmark.ips do |x|
      x.config(time: 5, warmup: 2)

      x.report('repeat(1) short') do
        simple_repeat_parser.parse(short_digits)
      end

      x.report('repeat(1) medium') do
        simple_repeat_parser.parse(medium_digits)
      end

      x.report('repeat(1) long') do
        simple_repeat_parser.parse(long_digits)
      end

      x.report('repeat(3,6) valid') do
        bounded_repeat_parser.parse('12345')
      end

      x.report('repeat maybe') do
        maybe_repeat_parser.parse(medium_digits)
      end

      x.compare!
    end
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

    simple_tree = { number: '123' }
    medium_tree = [{ number: '123' }, { word: 'hello' }, { number: '456' }]
    complex_tree = {
      list: [
        { pair: { key: 'name', value: { word: 'john' } } },
        { pair: { key: 'age', value: { number: '30' } } },
      ],
    }

    Benchmark.ips do |x|
      x.config(time: 5, warmup: 2)

      x.report('simple transform') do
        simple_transform.apply(simple_tree)
      end

      x.report('medium transform') do
        simple_transform.apply(medium_tree)
      end

      x.report('complex transform') do
        complex_transform.apply(complex_tree)
      end

      x.compare!
    end
    puts
  end
end

BenchmarkSuite.run_all if __FILE__ == $0
