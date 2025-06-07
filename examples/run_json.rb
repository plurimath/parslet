#!/usr/bin/env ruby

# This example demonstrates the JSON parser and transformer
# It parses JSON strings and converts them to Ruby objects

require_relative '../spec/fixtures/examples/json'
require 'pp'

# JSON string to parse
json_string = %{
  [ 1, 2, 3, null,
    "asdfasdf asdfds", { "a": -1.2 }, { "b": true, "c": false },
    0.1e24, true, false, [ 1 ] ]
}

puts "Parsing JSON string:"
puts json_string
puts "\n" + "="*50 + "\n"

begin
  # Parse the JSON
  parser = MyJson::Parser.new
  transformer = MyJson::Transformer.new

  tree = parser.parse(json_string)

  puts "Parse tree:"
  pp tree
  puts "\n" + "-"*50 + "\n"

  # Transform to Ruby objects
  result = transformer.apply(tree)

  puts "Transformed to Ruby objects:"
  pp result

  # Verify the result
  expected = [
    1, 2, 3, nil,
    "asdfasdf asdfds", { "a" => -1.2 }, { "b" => true, "c" => false },
    0.1e24, true, false, [ 1 ]
  ]

  puts "\n" + "-"*50 + "\n"
  puts "Verification:"
  if result == expected
    puts "✓ JSON parsing successful! Result matches expected output."
  else
    puts "✗ JSON parsing failed. Result does not match expected output."
    puts "Expected:"
    pp expected
  end

rescue Parslet::ParseFailed => error
  puts "Parse failed:"
  puts error.parse_failure_cause.ascii_tree
end
