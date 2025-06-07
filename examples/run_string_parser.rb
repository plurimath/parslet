#!/usr/bin/env ruby

# This example demonstrates string parsing with literal files
# Shows how to parse string literals and handle file-based input

require_relative '../spec/fixtures/examples/string_parser'
require 'pp'

# Sample literal content (inline for demonstration)
literal_content = <<~LITERAL
  "Hello, World!"
  'Single quoted string'
  "String with \"escaped\" quotes"
  'String with \'escaped\' quotes'
  "Multi-line
  string content"
  "String with special chars: \n\t\r"
LITERAL

puts "String Parser Demo"
puts "Demonstrates parsing string literals with various formats"
puts "\n" + "="*50 + "\n"

begin
  # Parse the literal content
  parser = LiteralsParser.new
  result = parser.parse(literal_content)

  puts "Literal content:"
  puts literal_content
  puts "\n" + "-"*40 + "\n"

  puts "Parse tree:"
  pp result

  puts "\n" + "-"*40 + "\n"
  puts "Status: ✓ Parse successful"

rescue Parslet::ParseFailed => error
  puts "Status: ✗ Parse failed"
  puts "Error location:"
  puts error.parse_failure_cause.ascii_tree
rescue => error
  puts "Status: ✗ Error"
  puts "Error: #{error.message}"
end

puts "\nThis parser handles:"
puts "- Double-quoted strings"
puts "- Single-quoted strings"
puts "- Escaped quotes within strings"
puts "- Multi-line string content"
puts "- Special escape sequences"
puts "- File-based literal parsing"
