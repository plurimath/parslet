#!/usr/bin/env ruby

# This example demonstrates a precedence calculator
# Shows advanced operator precedence handling and expression evaluation

require_relative '../spec/fixtures/examples/prec_calc'
require 'pp'

# Create parser and transformer instances
parser = PrecCalcExample::Parser.new
transformer = PrecCalcExample::Transform.new

# Test mathematical expressions with various precedence levels
test_expressions = [
  "1 + 2 * 3",
  "2 * 3 + 4",
  "(1 + 2) * 3",
  "2 ^ 3 * 4",
  "2 * 3 ^ 2",
  "1 + 2 * 3 ^ 2",
  "(1 + 2) * (3 + 4)",
  "2 ^ 3 ^ 2",
  "10 - 3 * 2 + 1"
]

puts "Precedence Calculator Demo"
puts "Demonstrates advanced operator precedence and expression evaluation"
puts "\n" + "="*60 + "\n"

test_expressions.each do |expression|
  puts "Expression: #{expression}"

  begin
    # Parse the expression
    parse_tree = parser.parse(expression)
    puts "  Parse tree:"
    pp parse_tree

    # Evaluate the expression
    result = transformer.apply(parse_tree)
    puts "  Result: #{result}"
    puts "  Status: ✓ Calculation successful"

  rescue Parslet::ParseFailed => error
    puts "  Status: ✗ Parse failed"
    puts "  Error: #{error.message}"
  rescue => error
    puts "  Status: ✗ Evaluation failed"
    puts "  Error: #{error.message}"
  end

  puts "-" * 50
end

puts "\nThis calculator demonstrates:"
puts "- Operator precedence (^ > */ > +-)"
puts "- Parentheses for grouping"
puts "- Right associativity for exponentiation"
puts "- Left associativity for other operators"
puts "- Complex expression evaluation"
