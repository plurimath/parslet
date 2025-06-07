#!/usr/bin/env ruby

# This example demonstrates documentation parsing
# Shows how to parse structured documentation with various formats

require_relative '../spec/fixtures/examples/documentation'
require 'pp'

# Create parser instance
parser = DocumentationExample::Parser.new

# Sample documentation content
doc_samples = [
  "# Main Title\n\nSome content here.",
  "## Section Header\n\nMore content.",
  "### Subsection\n\nDetailed information.",
  "- List item 1\n- List item 2\n- List item 3",
  "1. Numbered item\n2. Another item\n3. Final item",
  "**Bold text** and *italic text*",
  "`code snippet` in text",
  "```\ncode block\nwith multiple lines\n```"
]

puts "Documentation Parser Demo"
puts "Demonstrates parsing structured documentation with various formats"
puts "\n" + "="*60 + "\n"

doc_samples.each_with_index do |doc, index|
  puts "Sample #{index + 1}:"
  puts doc.inspect
  puts

  begin
    result = parser.parse(doc)
    puts "  Parse tree:"
    pp result
    puts "  Status: ✓ Parse successful"

  rescue Parslet::ParseFailed => error
    puts "  Status: ✗ Parse failed"
    puts "  Error: #{error.message}"
  end

  puts "-" * 50
end

puts "\nThis documentation parser supports:"
puts "- Headers (# ## ###)"
puts "- Bullet lists (- item)"
puts "- Numbered lists (1. item)"
puts "- Bold and italic text"
puts "- Inline code (`code`)"
puts "- Code blocks (```)"
puts "- Structured content parsing"
