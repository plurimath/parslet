require 'parslet'

# A small example that shows a really small parser and what happens on parser
# errors. This is used for documentation purposes to demonstrate basic
# parslet functionality and error handling.

module DocumentationExample
  class MyParser < Parslet::Parser
    rule(:a) { str('a').repeat }

    def parse(str)
      a.parse(str)
    end
  end

  def self.parse_a_sequence(input)
    parser = MyParser.new
    parser.parse(input)
  end

  def self.demonstrate_success
    parse_a_sequence('aaaa')
  end

  def self.demonstrate_failure
    begin
      parse_a_sequence('bbbb')
    rescue Parslet::ParseFailed => e
      e
    end
  end
end
