#!/usr/bin/env ruby

# This example demonstrates a minimal Lisp parser
# Shows how to parse and evaluate simple Lisp expressions

require_relative '../spec/fixtures/examples/minilisp'
require 'pp'

# Create parser and transformer instances
parser = MiniLisp::Parser.new
transformer = MiniLisp::Transform.new

# Test Lisp expressions
test_expressions = [
  "(+ 1 2)",
  "(* 3 4)",
  "(hello world)",
  "(foo bar baz)",
  '("string" 42)',
  "(nested (inner expression))",
  "(+ 1.5 2.3)",
  "(identifier_with_underscores)"
]

puts "Mini Lisp Parser Demo"
puts "Demonstrates parsing and evaluating simple Lisp expressions"
puts "\n" + "="*60 + "\n"

test_expressions.each do |expression|
  puts "Expression: #{expression}"

  begin
    # Parse the expression
    parse_tree = parser.parse(expression)
    puts "  Parse tree:"
    pp parse_tree

    # Transform the expression
    result = transformer.do(parse_tree)
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

  puts "-" * 50
end

puts "\nThis Mini Lisp parser supports:"
puts "- S-expression syntax with parentheses"
puts "- Identifiers and symbols"
puts "- Integer and float literals"
puts "- String literals with escaping"
puts "- Nested expressions"
puts "- Whitespace handling"
puts "- Parse tree transformation"
