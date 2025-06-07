#!/usr/bin/env ruby

# This example demonstrates ERB template parsing
# Shows how to parse embedded Ruby code within templates

require_relative '../spec/fixtures/examples/erb'
require 'pp'

# Create parser instance
parser = ErbParser.new

# Test ERB templates
test_templates = [
  "Hello <%= name %>!",
  "<% if user.admin? %>Admin<% end %>",
  "Items: <% items.each do |item| %><%= item %><% end %>",
  "Plain text without ERB",
  "<%= 1 + 2 + 3 %>",
  "Mixed content: <%= greeting %> and <% code_block %> here"
]

puts "ERB Template Parser Demo"
puts "Parses embedded Ruby code within templates"
puts "\n" + "="*50 + "\n"

test_templates.each_with_index do |template, index|
  puts "Template #{index + 1}: #{template}"

  begin
    result = parser.parse(template)
    puts "  Parse tree:"
    pp result
    puts "  Status: ✓ Parse successful"

  rescue Parslet::ParseFailed => error
    puts "  Status: ✗ Parse failed"
    puts "  Error: #{error.parse_failure_cause.ascii_tree}"
  end

  puts "-" * 50
end

puts "\nThis ERB parser recognizes:"
puts "- <%= %> tags for output expressions"
puts "- <% %> tags for code blocks"
puts "- Plain text content"
puts "- Mixed content with multiple ERB tags"
