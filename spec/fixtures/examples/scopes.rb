require 'parslet'

# Demonstrates scope handling in parslet - how captures can be scoped
# and how dynamic parsing can access captured values.

module ScopesExample
  def self.create_parser
    Parslet.str('a').capture(:a) >> Parslet.scope { Parslet.str('b').capture(:a) } >>
      Parslet.dynamic { |s,c| Parslet.str(c.captures[:a]) }
  end

  def self.parse_scoped_input(input = 'aba')
    parser = create_parser
    parser.parse(input)
  end

  def self.demonstrate_scope_success
    parse_scoped_input('aba')
  end

  def self.demonstrate_scope_failure
    begin
      parse_scoped_input('abc')
    rescue Parslet::ParseFailed => e
      e
    end
  end

  # Simpler nested scope example that actually works
  def self.create_nested_scope_parser
    Parslet.str('x').capture(:outer) >>
      Parslet.scope {
        Parslet.str('y').capture(:outer) >>
        Parslet.dynamic { |s,c| Parslet.str(c.captures[:outer]) }
      } >>
      Parslet.dynamic { |s,c| Parslet.str(c.captures[:outer]) }
  end

  def self.parse_nested_scoped_input(input = 'xyyx')
    parser = create_nested_scope_parser
    parser.parse(input)
  end
end
