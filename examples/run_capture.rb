#!/usr/bin/env ruby

# This example demonstrates named capture groups in parslet
# Shows how to use .as(:name) to create structured parse trees

require_relative '../spec/fixtures/examples/capture'
require 'pp'

# Create parser instance
parser = CaptureExample::Parser.new

# Test strings
test_cases = [
  "hello world",
  "foo bar baz",
  "single",
  "multiple words here"
]

puts "Named Capture Groups Demo"
puts "Demonstrates how to use .as(:name) for structured parsing"
puts "\n" + "="*50 + "\n"

test_cases.each do |input|
  puts "Input: '#{input}'"

  begin
    result = parser.parse(input)
    puts "  Parse tree:"
    pp result
    puts "  Status: ✓ Parse successful"

  rescue Parslet::ParseFailed => error
    puts "  Status: ✗ Parse failed"
    puts "  Error: #{error.message}"
  end

  puts "-" * 40
end

puts "\nThis example shows:"
puts "- Using .as(:name) to create named captures"
puts "- Building structured parse trees"
puts "- How captures help organize parsing results"
