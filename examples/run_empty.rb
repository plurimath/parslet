#!/usr/bin/env ruby

# This example demonstrates empty rule behavior in parslet
# Shows how parsers handle empty input and optional rules

require_relative '../spec/fixtures/examples/empty'
require 'pp'

# Create parser instance
parser = EmptyExample::Parser.new

# Test cases including empty input
test_cases = [
  "",
  "a",
  "aa",
  "aaa",
  "b",
  "ab",
  "ba"
]

puts "Empty Rule Behavior Demo"
puts "Demonstrates how parslet handles empty input and optional rules"
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

  puts "-" * 30
end

puts "\nThis example demonstrates:"
puts "- How parslet handles empty input"
puts "- Optional rule behavior (.maybe)"
puts "- Repetition with zero matches (.repeat)"
puts "- Empty string parsing strategies"
