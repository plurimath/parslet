#!/usr/bin/env ruby

# This example demonstrates nested error handling in parslet
# Shows how parslet handles errors in nested parsing structures

require_relative '../spec/fixtures/examples/nested_errors'
require 'pp'

# Create parser instance
parser = NestedErrorsExample::Parser.new

# Test cases with various nested structures and errors
test_cases = [
  "valid nested structure",
  "partially { valid } structure",
  "invalid { nested { structure",
  "{ properly { nested } structure }",
  "mismatched { brackets ]",
  "{ { { deeply nested } } }"
]

puts "Nested Error Handling Demo"
puts "Demonstrates how parslet handles errors in nested parsing structures"
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
    puts "  Error location and context:"
    puts error.parse_failure_cause.ascii_tree
    puts "  Nested error details:"
    puts "    Position: #{error.parse_failure_cause.pos}"
    puts "    Expected: #{error.parse_failure_cause.expected}"
  end

  puts "-" * 60
end

puts "\nThis example demonstrates:"
puts "- Error handling in nested parsing structures"
puts "- How parslet tracks context through nesting levels"
puts "- Detailed error reporting for complex nested failures"
puts "- Error recovery strategies in recursive parsers"
puts "- Debugging techniques for nested grammar issues"
