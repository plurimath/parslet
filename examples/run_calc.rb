#!/usr/bin/env ruby

# This example demonstrates a simple integer calculator
# It shows how to handle left and right associativity in parslet (PEG)
# Supports addition, subtraction, multiplication, and division with proper precedence

require_relative '../spec/fixtures/examples/calc'
require 'pp'

# Test expressions
test_expressions = [
  "1 + 2",
  "3 * 4 + 5",
  "10 - 3 * 2",
  "15 / 3 + 2 * 4",
  "100 + 20 * 3 - 5",
  "2 * 3 * 4",
  "20 / 4 / 2"
]

puts "Integer Calculator Demo"
puts "Demonstrates operator precedence and left associativity"
puts "\n" + "="*50 + "\n"

test_expressions.each do |expression|
  puts "Expression: #{expression}"

  begin
    result = CalcExample.calculate(expression)
    puts "  Result: #{result}"
    puts "  Status: ✓ Calculation successful"

  rescue Parslet::ParseFailed => error
    puts "  Status: ✗ Parse failed"
    puts "  Error: #{error.message}"
  rescue => error
    puts "  Status: ✗ Calculation failed"
    puts "  Error: #{error.message}"
  end

  puts "-" * 30
end

puts "\nThis calculator demonstrates:"
puts "- Operator precedence (* and / before + and -)"
puts "- Left associativity for same-precedence operators"
puts "- Integer arithmetic with proper evaluation order"
puts "- Abstract syntax tree construction and evaluation"
