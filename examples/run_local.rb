#!/usr/bin/env ruby

# This example demonstrates local variable scoping in parslet
# Shows how to handle local variables and scoping in parsing

require_relative '../spec/fixtures/examples/local'
require 'pp'

# Create parser instance
parser = LocalExample::Parser.new

# Test cases with local variable declarations and usage
test_cases = [
  "let x = 5",
  "let y = 10; y",
  "let a = 1; let b = 2; a + b",
  "let x = 5; let x = 10; x",  # Variable shadowing
  "x",  # Undefined variable
  "let z = 3; let w = z; w"
]

puts "Local Variable Scoping Demo"
puts "Demonstrates local variable handling and scoping in parslet"
puts "\n" + "="*50 + "\n"

test_cases.each_with_index do |code, index|
  puts "Test #{index + 1}: #{code}"

  begin
    result = parser.parse(code)
    puts "  Parse tree:"
    pp result
    puts "  Status: ✓ Parse successful"

  rescue Parslet::ParseFailed => error
    puts "  Status: ✗ Parse failed"
    puts "  Error: #{error.message}"
  end

  puts "-" * 40
end

puts "\nThis example demonstrates:"
puts "- Local variable declaration (let statements)"
puts "- Variable scoping and resolution"
puts "- Variable shadowing behavior"
puts "- Error handling for undefined variables"
puts "- Sequential variable assignments"
