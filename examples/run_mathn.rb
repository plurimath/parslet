#!/usr/bin/env ruby

# This example demonstrates mathn compatibility
# Shows how parslet works with Ruby's mathn library (deprecated in Ruby 2.5+)

require_relative '../spec/fixtures/examples/mathn'
require 'pp'

puts "Mathn Compatibility Demo"
puts "Demonstrates parslet compatibility with Ruby's mathn library"
puts "Note: mathn is deprecated in Ruby 2.5+ and removed in Ruby 3.0+"
puts "\n" + "="*60 + "\n"

begin
  # Create parser instance
  parser = MathnExample::Parser.new

  # Test mathematical expressions
  test_cases = [
    "1",
    "42",
    "3.14",
    "1/2",
    "2/3"
  ]

  test_cases.each do |input|
    puts "Input: #{input}"

    begin
      result = parser.parse(input)
      puts "  Parse tree:"
      pp result
      puts "  Status: ✓ Parse successful"

    rescue Parslet::ParseFailed => error
      puts "  Status: ✗ Parse failed"
      puts "  Error: #{error.message}"
    end

    puts "-" * 30
  end

rescue LoadError => e
  puts "Mathn library not available: #{e.message}"
  puts "This is expected in Ruby 3.0+ where mathn was removed."
rescue => e
  puts "Error loading mathn example: #{e.message}"
end

puts "\nThis example shows:"
puts "- Compatibility with Ruby's mathn library"
puts "- Handling of rational numbers"
puts "- Graceful degradation when mathn is unavailable"
