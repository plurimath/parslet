#!/usr/bin/env ruby

# This example demonstrates the power of tree pattern matching with parentheses
# It parses balanced parentheses and counts the nesting depth
# Uses '.as(:name)' to construct a tree that can reliably be matched afterwards

require_relative '../spec/fixtures/examples/parens'
require 'pp'

# Create parser and transformer instances
parser = LISP::Parser.new
transform = LISP::Transform.new

# Test expressions with various parentheses patterns
test_expressions = %w[
  ()
  (())
  ((((()))))
  ((())
]

puts "Parsing balanced parentheses expressions:"
puts "Demonstrates tree pattern matching and nesting depth counting"
puts "\n" + "="*60 + "\n"

test_expressions.each do |pexp|
  puts "Expression: #{pexp}"

  begin
    result = parser.parse(pexp)
    depth = transform.apply(result)

    puts "  Parse tree: #{result.inspect}"
    puts "  Nesting depth: #{depth} parens"
    puts "  Status: ✓ Valid balanced parentheses"

  rescue Parslet::ParseFailed => error
    puts "  Status: ✗ Parse failed"
    puts "  Error: #{error.message}"
  end

  puts "-" * 40
end

puts "\nThis example shows how Parslet can:"
puts "- Parse recursive structures (nested parentheses)"
puts "- Use tree pattern matching with .as(:name)"
puts "- Transform parse trees into meaningful data (depth count)"
puts "- Handle malformed input gracefully"
