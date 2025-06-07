#!/usr/bin/env ruby

# This example demonstrates scope handling in parslet
# Shows how to manage variable scopes and nested contexts

require_relative '../spec/fixtures/examples/scopes'
require 'pp'

# Create parser instance
parser = ScopesExample::Parser.new

# Test cases demonstrating scope handling
test_cases = [
  "{ var x = 1; x }",
  "{ var x = 1; { var y = 2; x + y } }",
  "{ var x = 1; { var x = 2; x } }",  # Variable shadowing
  "var global = 10; { global }",
  "{ var a = 1; { var b = 2; { var c = 3; a + b + c } } }",
  "{ var x = 1; } x"  # Variable out of scope
]

puts "Scope Handling Demo"
puts "Demonstrates variable scopes and nested contexts in parslet"
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

  puts "-" * 50
end

puts "\nThis example demonstrates:"
puts "- Block scoping with { }"
puts "- Variable declarations within scopes"
puts "- Variable shadowing in nested scopes"
puts "- Scope resolution and variable lookup"
puts "- Out-of-scope variable access errors"
puts "- Nested context management"
