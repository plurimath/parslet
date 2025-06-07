#!/usr/bin/env ruby

# This example demonstrates a simple XML parser
# It parses basic XML structures and validates matching tags
# Note: This is a simplified parser that doesn't address all XML complexities

require_relative '../spec/fixtures/examples/simple_xml'
require 'pp'

# Test XML strings
test_cases = [
  "<a><b>some text in the tags</b></a>",
  "<b><b>some text in the tags</b></a>",  # Mismatched tags
  "<root><child>content</child></root>",
  "<single></single>",
  "<nested><level1><level2>deep content</level2></level1></nested>"
]

puts "Simple XML Parser Demo"
puts "Parses basic XML and validates matching open/close tags"
puts "\n" + "="*60 + "\n"

test_cases.each_with_index do |xml, index|
  puts "Test case #{index + 1}: #{xml}"

  begin
    # Parse the XML
    parser = XML.new
    result = parser.parse(xml)

    puts "  Parse tree:"
    pp result

    # Validate with the check function
    validation_result = check(xml)

    puts "  Validation result: #{validation_result.inspect}"

    if validation_result == "verified"
      puts "  Status: ✓ Valid XML with matching tags"
    else
      puts "  Status: ⚠ Parsed but validation incomplete"
    end

  rescue Parslet::ParseFailed => error
    puts "  Status: ✗ Parse failed"
    puts "  Error: #{error.message}"
  rescue => error
    puts "  Status: ✗ Validation failed"
    puts "  Error: #{error.message}"
  end

  puts "-" * 50
end

puts "\nThis example demonstrates:"
puts "- Basic XML parsing with nested tags"
puts "- Tag validation using transformations"
puts "- Error handling for malformed XML"
puts "- Tree pattern matching for validation"
