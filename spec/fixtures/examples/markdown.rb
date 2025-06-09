$:.unshift File.dirname(__FILE__) + "/../lib"

require 'parslet'

class MarkdownParser < Parslet::Parser
  include Parslet
  root :document

  # Whitespace rules
  rule(:space) { match('\s') }
  rule(:spaces) { space.repeat(1) }
  rule(:spaces?) { space.repeat }
  rule(:newline) { str("\n") }
  rule(:line_end) { newline }

  # Basic text elements
  rule(:word) { match('[^\s\n*`#\[\]()]').repeat(1) }
  rule(:text_char) { match('[^\n*`\[\]()]') }
  rule(:plain_text) { (text_char.repeat(1) >> spaces?).repeat(1) }

  # Headers (# ## ### etc.)
  rule(:header) {
    (str('#').repeat(1, 6).as(:level) >>
     spaces >>
     (match('[^\n]').repeat).as(:text) >>
     line_end).as(:header)
  }

  # Bold text (**text**)
  rule(:bold) {
    (str('**') >>
     (str('**').absent? >> any).repeat(1).as(:text) >>
     str('**')).as(:bold)
  }

  # Italic text (*text*)
  rule(:italic) {
    (str('*') >>
     (str('*').absent? >> any).repeat(1).as(:text) >>
     str('*')).as(:italic)
  }

  # Inline code (`code`)
  rule(:inline_code) {
    (str('`') >>
     (str('`').absent? >> any).repeat(1).as(:text) >>
     str('`')).as(:inline_code)
  }

  # Code blocks (```code```)
  rule(:code_block) {
    (str('```') >>
     (match('[^\n]').repeat).as(:language) >>
     newline >>
     (str('```').absent? >> any).repeat.as(:code) >>
     str('```') >>
     line_end.maybe).as(:code_block)
  }

  # Links ([text](url))
  rule(:link) {
    (str('[') >>
     (str(']').absent? >> any).repeat(1).as(:text) >>
     str('](') >>
     (str(')').absent? >> any).repeat(1).as(:url) >>
     str(')')).as(:link)
  }

  # List items (- item)
  rule(:list_item) {
    (str('-') >>
     spaces >>
     (match('[^\n]').repeat(1)).as(:text) >>
     line_end.maybe).as(:list_item)
  }

  # Inline elements (can appear within paragraphs)
  rule(:inline_element) {
    bold | italic | inline_code | link |
    (match('[^\n*`\[\]()]').repeat(1)).as(:text)
  }

  # Paragraph (text with inline formatting) - must not start with list marker
  rule(:paragraph) {
    (str('-').absent? >>
     inline_element.repeat(1) >>
     (newline >> newline).maybe).as(:paragraph)
  }

  # Block elements (order matters - more specific rules first)
  rule(:block_element) {
    code_block | header | list_item | paragraph
  }

  # Document structure
  rule(:document) {
    spaces? >>
    (block_element >> spaces?).repeat.as(:document) >>
    spaces?
  }
end

class MarkdownTransformer < Parslet::Transform
  # Headers
  rule(header: { level: simple(:level), text: simple(:text) }) {
    {
      type: :header,
      level: level.to_s.length,
      text: text.to_s.strip
    }
  }

  # Bold text
  rule(bold: { text: simple(:text) }) {
    {
      type: :bold,
      text: text.to_s
    }
  }

  # Italic text
  rule(italic: { text: simple(:text) }) {
    {
      type: :italic,
      text: text.to_s
    }
  }

  # Inline code
  rule(inline_code: { text: simple(:text) }) {
    {
      type: :inline_code,
      text: text.to_s
    }
  }

  # Fallback rules for when the above don't match
  rule(bold: simple(:text)) { { type: :bold, text: text.to_s } }
  rule(italic: simple(:text)) { { type: :italic, text: text.to_s } }
  rule(inline_code: simple(:text)) { { type: :inline_code, text: text.to_s } }

  # Code blocks
  rule(code_block: { language: simple(:lang), code: simple(:code) }) {
    {
      type: :code_block,
      language: lang.to_s.strip,
      code: code.to_s
    }
  }

  # Links
  rule(link: { text: simple(:text), url: simple(:url) }) {
    {
      type: :link,
      text: text.to_s,
      url: url.to_s
    }
  }

  # List items
  rule(list_item: { text: simple(:text) }) {
    {
      type: :list_item,
      text: text.to_s.strip
    }
  }

  # Fallback for list items that don't match the above pattern
  rule(list_item: simple(:text)) {
    {
      type: :list_item,
      text: text.to_s.strip
    }
  }

  # Text nodes
  rule(text: simple(:text)) {
    text.to_s
  }

  # Paragraphs
  rule(paragraph: subtree(:content)) {
    {
      type: :paragraph,
      content: content.is_a?(Array) ? content : [content]
    }
  }

  # Document
  rule(document: subtree(:blocks)) {
    {
      type: :document,
      blocks: blocks.is_a?(Array) ? blocks : [blocks]
    }
  }
end

# Convenience method for parsing markdown
def parse_markdown(text)
  parser = MarkdownParser.new
  transformer = MarkdownTransformer.new

  tree = parser.parse(text)
  transformer.apply(tree)
end
