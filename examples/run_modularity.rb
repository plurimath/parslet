#!/usr/bin/env ruby

# This example demonstrates modularity in parslet
# Shows how to create modular, reusable parser components

require_relative '../spec/fixtures/examples/modularity'
require 'pp'

# Create parser instance
parser = ModularityExample::Parser.new

# Test cases demonstrating modular parsing
test_cases = [
  "module A { function foo() { return 42; } }",
  "module B { var x = 10; function bar() { return x; } }",
  "module C { import A; function baz() { return A.foo(); } }",
  "function standalone() { return 'hello'; }",
  "var global = 100;",
  "module D { module E { function nested() { return true; } } }"
]

puts "Modularity Parser Demo"
puts "Demonstrates modular, reusable parser components"
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
puts "- Modular parser design"
puts "- Reusable parsing components"
puts "- Module and function declarations"
puts "- Import statements"
puts "- Nested module structures"
puts "- Component composition in parslet"
