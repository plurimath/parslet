#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib'

require 'benchmark/ips'
require 'parslet'

class ExampleBenchmarks
  def self.run_all
    puts 'Plurimath Parslet Example Benchmarks'
    puts '=' * 40
    puts

    new.run_calculator_benchmark
    new.run_json_benchmark
    new.run_email_benchmark
    new.run_simple_xml_benchmark
  end

  def run_calculator_benchmark
    puts 'Calculator Example Benchmark'
    puts '-' * 30

    # Load the calculator example
    require_relative '../example/calc'

    expressions = [
      '1+2',
      '1+2*3',
      '123*456+789',
      '1+2*3-4/5+6*7-8/9',
      '123*2+456-789/3',
    ]

    calc_parser = CalcParser.new

    Benchmark.ips do |x|
      x.config(time: 3, warmup: 1)

      expressions.each do |expr|
        x.report("calc parse: #{expr}") do
          calc_parser.parse(expr)
        end
      end

      x.report('calc full pipeline') do
        calculate('1+2*3-4/2')
      end

      x.compare!
    end
    puts
  end

  def run_json_benchmark
    puts 'JSON Example Benchmark'
    puts '-' * 30

    # Load the JSON example
    require_relative '../example/json'

    json_examples = [
      '{"key": "value"}',
      '[1, 2, 3, 4, 5]',
      '{"name": "John", "age": 30, "active": true}',
      '[{"id": 1, "name": "Alice"}, {"id": 2, "name": "Bob"}]',
    ]

    json_parser = MyJson::Parser.new

    Benchmark.ips do |x|
      x.config(time: 3, warmup: 1)

      json_examples.each_with_index do |json, i|
        x.report("json parse #{i + 1}") do
          json_parser.parse(json)
        end
      end

      # Skip full pipeline due to Ruby 3.3 compatibility issue
      # x.report('json full pipeline') do
      #   MyJson.parse('{"test": [1, 2, 3]}')
      # end

      x.compare!
    end
    puts
  end

  def run_email_benchmark
    puts 'Email Parser Benchmark'
    puts '-' * 30

    # Create a simple email parser
    email_parser = Class.new(Parslet::Parser) do
      root :email
      rule(:email) { local_part >> str('@') >> domain }
      rule(:local_part) { match('[a-zA-Z0-9._-]').repeat(1) }
      rule(:domain) { subdomain >> (str('.') >> subdomain).repeat(1) }
      rule(:subdomain) { match('[a-zA-Z0-9-]').repeat(1) }
    end.new

    emails = [
      'user@example.com',
      'john.doe@company.org',
      'test_user123@sub.domain.co.uk',
      'a@b.c',
    ]

    Benchmark.ips do |x|
      x.config(time: 3, warmup: 1)

      emails.each do |email|
        x.report("email: #{email}") do
          email_parser.parse(email)
        end
      end

      x.compare!
    end
    puts
  end

  def run_simple_xml_benchmark
    puts 'Simple XML Benchmark'
    puts '-' * 30

    # Create a simple XML parser
    xml_parser = Class.new(Parslet::Parser) do
      root :document
      rule(:document) { element }
      rule(:element) do
        str('<') >> tag_name.as(:open_tag) >> str('>') >>
          content.as(:content) >>
          str('</') >> tag_name.as(:close_tag) >> str('>')
      end
      rule(:tag_name) { match('[a-zA-Z0-9]').repeat(1) }
      rule(:content) { (str('<').absent? >> any).repeat }
    end.new

    xml_examples = [
      '<p>Hello</p>',
      '<div>Content here</div>',
      '<title>Page Title</title>',
      '<h1>Header Text</h1>',
    ]

    Benchmark.ips do |x|
      x.config(time: 3, warmup: 1)

      xml_examples.each_with_index do |xml, i|
        x.report("xml #{i + 1}") do
          xml_parser.parse(xml)
        end
      end

      x.compare!
    end
    puts
  end
end

ExampleBenchmarks.run_all if __FILE__ == $0
