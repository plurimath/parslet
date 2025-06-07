#!/usr/bin/env ruby

# This example demonstrates the README parser
# Shows how to parse README-style documentation with various sections

require_relative '../spec/fixtures/examples/readme'
require 'pp'

# Create parser instance
parser = ReadmeExample::Parser.new

# Sample README content
readme_content = <<~README
  # Project Title

  A brief description of the project.

  ## Installation

  ```bash
  gem install project-name
  ```

  ## Usage

  Basic usage example:

  ```ruby
  require 'project'
  Project.new.run
  ```

  ## Contributing

  1. Fork the repository
  2. Create a feature branch
  3. Submit a pull request

  ## License

  MIT License
README

puts "README Parser Demo"
puts "Demonstrates parsing README-style documentation"
puts "\n" + "="*50 + "\n"

begin
  result = parser.parse(readme_content)

  puts "README content:"
  puts readme_content
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

puts "\nThis README parser supports:"
puts "- Headers (# ##)"
puts "- Paragraphs and text content"
puts "- Code blocks with language tags"
puts "- Numbered and bulleted lists"
puts "- Standard README sections"
puts "- Structured document parsing"
