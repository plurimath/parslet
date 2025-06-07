#!/usr/bin/env ruby

# This example demonstrates the Boolean Algebra parser and transformer
# It parses strings like "var1 and (var2 or var3)" respecting operator precedence
# and parentheses, then transforms the parse tree into DNF (disjunctive normal form).

require_relative '../spec/fixtures/examples/boolean_algebra'
require 'pp'

# Create parser and transformer instances
parser = MyParser.new
transformer = Transformer.new

# Parse a boolean expression
expression = "var1 and (var2 or var3)"

puts "Parsing boolean expression:"
puts expression
puts "\n" + "="*50 + "\n"

begin
  # Parse the expression
  tree = parser.parse(expression)

  puts "Parse tree:"
  pp tree
  # {:and=>
  #   {:left=>{:var=>"1"@3},
  #    :right=>{:or=>{:left=>{:var=>"2"@13}, :right=>{:var=>"3"@21}}}}}

  puts "\n" + "-"*50 + "\n"

  # Transform to DNF
  result = transformer.apply(tree)

  puts "Transformed to DNF (Disjunctive Normal Form):"
  pp result
  # [["1", "2"], ["1", "3"]]

  puts "\nExplanation:"
  puts "The result represents: (var1 AND var2) OR (var1 AND var3)"
  puts "Each inner array is an AND clause, outer array connects with OR"

rescue Parslet::ParseFailed => error
  puts "Parse failed:"
  puts error.parse_failure_cause.ascii_tree
end
