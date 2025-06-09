#!/usr/bin/env ruby

$:.unshift File.dirname(__FILE__) + "/../lib"

require_relative '../spec/fixtures/examples/html5'

def print_separator(title = nil)
  puts "=" * 60
  puts title if title
  puts "=" * 60
end

def print_subseparator
  puts "-" * 40
end

def demonstrate_html5_parser
  puts "HTML5 Parser Demo"
  puts "Parses HTML5 syntax into structured DOM-like data"
  puts

  examples = [
    {
      name: "Simple HTML document",
      html: "<!DOCTYPE html>\n<html>\n<head>\n<title>Test</title>\n</head>\n<body>\n<h1>Hello World</h1>\n</body>\n</html>"
    },
    {
      name: "Void elements",
      html: '<img src="image.jpg" alt="Image"><br><input type="text" name="field">'
    },
    {
      name: "Unclosed paragraph tags",
      html: '<p>First paragraph\n<p>Second paragraph without closing tag\n<p>Third paragraph'
    },
    {
      name: "Nested elements with attributes",
      html: '<div class="container" id="main">\n  <span style="color: red">Red text</span>\n  <a href="https://example.com">Link</a>\n</div>'
    },
    {
      name: "Comments and mixed content",
      html: '<!-- This is a comment -->\n<p>Text with <strong>bold</strong> and <em>italic</em> formatting.</p>'
    },
    {
      name: "Form elements",
      html: '<form action="/submit" method="post">\n  <input type="text" name="username" required>\n  <input type="password" name="password">\n  <button type="submit">Submit</button>\n</form>'
    },
    {
      name: "Complex nested structure",
      html: '<!DOCTYPE html>\n<html lang="en">\n<head>\n  <meta charset="UTF-8">\n  <title>Complex Example</title>\n</head>\n<body>\n  <header>\n    <h1>Main Title</h1>\n    <nav>\n      <ul>\n        <li><a href="#home">Home</a>\n        <li><a href="#about">About</a>\n      </ul>\n    </nav>\n  </header>\n  <main>\n    <article>\n      <h2>Article Title</h2>\n      <p>Article content with <strong>bold</strong> text.\n      <img src="article.jpg" alt="Article image">\n    </article>\n  </main>\n</body>\n</html>'
    }
  ]

  examples.each_with_index do |example, index|
    print_separator("Test case #{index + 1}:")
    puts "Input HTML:"
    puts example[:html].inspect
    puts
    puts "HTML text:"
    puts example[:html]
    puts

    begin
      # Parse the HTML
      parser = HTML5Parser.new
      tree = parser.parse(example[:html])

      print_subseparator
      puts "Parse tree:"
      puts tree.inspect
      puts

      # Transform the parse tree
      transformer = HTML5Transformer.new
      result = transformer.apply(tree)

      puts "Transformed result:"
      puts result.inspect
      puts "Status: ✓ Successfully parsed"

    rescue Parslet::ParseFailed => e
      puts "Parse error: #{e.message}"
      puts "Status: ✗ Parse failed"
    rescue => e
      puts "Error: #{e.message}"
      puts "Status: ✗ Error occurred"
    end

    puts
  end

  print_separator
  puts "This example demonstrates:"
  puts "- DOCTYPE declaration parsing"
  puts "- Void elements (self-closing tags)"
  puts "- Container elements with optional closing tags"
  puts "- Attribute parsing (quoted and unquoted values)"
  puts "- Nested element structures"
  puts "- Comment handling"
  puts "- Text content extraction"
  puts "- HTML5 forgiving parsing (unclosed tags)"
  puts "- Complex document structure parsing"
end

if __FILE__ == $0
  demonstrate_html5_parser
end
