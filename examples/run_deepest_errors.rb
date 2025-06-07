#!/usr/bin/env ruby

# This example demonstrates deepest error reporting in parslet
# Shows how parslet reports the most specific parsing errors

require_relative '../spec/fixtures/examples/deepest_errors'
require 'pp'

# Create parser instance
parser = DeepestErrorsExample::Parser.new

# Test cases that will generate various parsing errors
test_cases = [
  "valid input",
  "partially valid but",
  "completely invalid",
  "almost correct syntax error",
  "nested error deep inside",
  ""
]

puts "Deepest Error Reporting Demo"
puts "Demonstrates how parslet reports the most specific parsing errors"
puts "\n" + "="*60 + "\n"

test_cases.each_with_index do |input, index|
  puts "Test #{index + 1}: '#{input}'"

  begin
    result = parser.parse(input)
    puts "  Parse tree:"
    pp result
    puts "  Status: ✓ Parse successful"

  rescue Parslet::ParseFailed => error
    puts "  Status: ✗ Parse failed"
    puts "  Deepest error location:"
    puts error.parse_failure_cause.ascii_tree
    puts "  Error details:"
    puts "    Position: #{error.parse_failure_cause.pos}"
    puts "    Expected: #{error.parse_failure_cause.expected}"
  end

  puts "-" * 60
end

puts "\nThis example demonstrates:"
puts "- How parslet tracks parsing progress"
puts "- Deepest error reporting (furthest successful parse)"
puts "- Detailed error messages with position information"
puts "- ASCII tree visualization of parse failures"
puts "- Error context for debugging complex grammars"
