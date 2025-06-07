#!/usr/bin/env ruby

# This example demonstrates comment parsing
# Shows how to handle different comment styles in source code

require_relative '../spec/fixtures/examples/comments'
require 'pp'

# Create parser instance
parser = CommentsExample::Parser.new

# Test code with comments
test_cases = [
  "// Single line comment",
  "/* Block comment */",
  "/* Multi-line\n   block comment */",
  "code(); // Comment after code",
  "/* Comment */ code(); /* Another comment */",
  "// First comment\n// Second comment",
  "nested /* outer /* inner */ outer */ comments"
]

puts "Comment Parser Demo"
puts "Parses different styles of comments in source code"
puts "\n" + "="*50 + "\n"

test_cases.each_with_index do |code, index|
  puts "Test #{index + 1}: #{code.inspect}"

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

puts "\nThis parser handles:"
puts "- Single-line comments (//)"
puts "- Block comments (/* */)"
puts "- Multi-line block comments"
puts "- Comments mixed with code"
puts "- Nested block comments"
