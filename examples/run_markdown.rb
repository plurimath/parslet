#!/usr/bin/env ruby

# This example demonstrates a simple Markdown parser
# It parses basic Markdown syntax and converts it to a structured format

require_relative '../spec/fixtures/examples/markdown'
require 'pp'

# Test Markdown strings
test_cases = [
  "# Main Header\n\nThis is a simple paragraph.",

  "## Subheader\n\nThis paragraph has **bold text** and *italic text*.",

  "Here's a [link](https://example.com) in a paragraph.",

  "Some `inline code` in text.",

  "```ruby\ndef hello\n  puts 'world'\nend\n```",

  "- First item\n- Second item\n- Third item",

  "# Complex Example\n\nThis paragraph has **bold**, *italic*, `code`, and a [link](https://test.com).\n\n## Code Section\n\n```javascript\nconsole.log('hello');\n```\n\n- List item one\n- List item two"
]

puts "Markdown Parser Demo"
puts "Parses basic Markdown syntax into structured data"
puts "\n" + "="*60 + "\n"

test_cases.each_with_index do |markdown, index|
  puts "Test case #{index + 1}:"
  puts "Input Markdown:"
  puts markdown.inspect
  puts "\nMarkdown text:"
  puts markdown
  puts "\n" + "-"*40

  begin
    # Parse the Markdown
    parser = MarkdownParser.new
    transformer = MarkdownTransformer.new

    tree = parser.parse(markdown)
    result = transformer.apply(tree)

    puts "Parse tree:"
    pp tree
    puts "\nTransformed result:"
    pp result

    puts "Status: ✓ Successfully parsed"

  rescue Parslet::ParseFailed => error
    puts "Status: ✗ Parse failed"
    puts "Error: #{error.message}"
    puts "\nDetailed error:"
    puts error.parse_failure_cause.ascii_tree if error.parse_failure_cause
  rescue => error
    puts "Status: ✗ Transformation failed"
    puts "Error: #{error.message}"
  end

  puts "\n" + "="*60 + "\n"
end

puts "This example demonstrates:"
puts "- Header parsing (# ## ###)"
puts "- Bold text (**text**)"
puts "- Italic text (*text*)"
puts "- Inline code (`code`)"
puts "- Code blocks (```code```)"
puts "- Links ([text](url))"
puts "- List items (- item)"
puts "- Paragraph handling"
puts "- Nested inline formatting"
puts "- Document structure parsing"
