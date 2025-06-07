require 'parslet'

module ReadmeExample
  include Parslet

  # Basic parslet examples from the readme
  class SimpleStringParser < Parslet::Parser
    root :simple_string

    rule(:simple_string) { quote >> content >> quote }
    rule(:quote) { str('"') }
    rule(:content) { (quote.absent? >> any).repeat }
  end

  class SmalltalkParser < Parslet::Parser
    root :smalltalk

    rule(:smalltalk) { statements }
    rule(:statements) {
      # Simple implementation for demo purposes
      str('smalltalk')
    }
  end

  # Demonstrate basic parslet functionality
  def self.demo_basic_parsing
    # String parsing
    foo_parser = Parslet.str('foo')
    foo_result = foo_parser.parse('foo')

    # Character set matching
    abc_parser = Parslet.match('[abc]')
    a_result = abc_parser.parse('a')
    b_result = abc_parser.parse('b')
    c_result = abc_parser.parse('c')

    # Annotation
    annotated_parser = Parslet.str('foo').as(:important_bit)
    annotated_result = annotated_parser.parse('foo')

    {
      foo: foo_result,
      a: a_result,
      b: b_result,
      c: c_result,
      annotated: annotated_result
    }
  end

  def self.demo_simple_string
    quote = Parslet.str('"')
    simple_string = quote >> (quote.absent? >> Parslet.any).repeat >> quote
    simple_string.parse('"Simple Simple Simple"')
  end

  def self.demo_smalltalk
    SmalltalkParser.new.parse('smalltalk')
  end
end
