#!/usr/bin/env ruby

# This example demonstrates transform chains in parslet
# Shows how to chain multiple transformations together

require_relative '../spec/fixtures/examples/seasons'
require 'pp'

# Create parser and transformer instances
parser = SeasonsExample::Parser.new
transformer = SeasonsExample::Transform.new

# Test season expressions
test_cases = [
  "spring",
  "summer",
  "autumn",
  "winter",
  "fall",
  "invalid_season"
]

puts "Transform Chains Demo"
puts "Demonstrates chaining multiple transformations in parslet"
puts "\n" + "="*50 + "\n"

test_cases.each do |input|
  puts "Input: '#{input}'"

  begin
    # Parse the input
    parse_tree = parser.parse(input)
    puts "  Parse tree:"
    pp parse_tree

    # Apply transformation
    result = transformer.apply(parse_tree)
    puts "  Transformed result:"
    pp result
    puts "  Status: ✓ Parse and transform successful"

  rescue Parslet::ParseFailed => error
    puts "  Status: ✗ Parse failed"
    puts "  Error: #{error.message}"
  rescue => error
    puts "  Status: ✗ Transform failed"
    puts "  Error: #{error.message}"
  end

  puts "-" * 40
end

puts "\nThis example demonstrates:"
puts "- Parsing season names"
puts "- Transforming parse trees into structured data"
puts "- Chaining multiple transformation rules"
puts "- Error handling in transformation chains"
