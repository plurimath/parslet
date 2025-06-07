# An exploration of two ideas:
#   a) Constructing a whole parser inline, without the artificial class around
#      it.
# and:
#   b) Constructing non-greedy or non-blind parsers by transforming the
#      grammar.

require 'parslet'

module LocalExample
  extend Parslet

  def self.this(name, &block)
    Parslet::Atoms::Entity.new(name, &block)
  end

  def self.epsilon
    any.absent?
  end

  # Traditional repetition will try as long as the pattern can be matched and
  # then give up. This is greedy and blind.
  def self.greedy_blind_parser
    str('a').as(:e) >> this('a') { greedy_blind_parser }.as(:rec) | epsilon
  end

  # Here's a pattern match that is greedy and non-blind. The first pattern
  # 'a'* will be tried as many times as possible, while still matching the
  # end pattern 'aa'.
  def self.greedy_non_blind_parser
    str('aa').as(:e2) >> epsilon | str('a').as(:e1) >> this('b') { greedy_non_blind_parser }.as(:rec)
  end

  # Simple inline parser without class wrapper - fixed to prevent infinite loops
  # This parser matches exactly 'aa' or 'aaa' or longer sequences ending in 'aa'
  def self.simple_inline_parser
    str('aa') | str('aaa') | str('aaaa') | str('aaaaa') | str('aaaaaa')
  end

  def self.parse_with_greedy_blind(input)
    greedy_blind_parser.parse(input)
  end

  def self.parse_with_greedy_non_blind(input)
    greedy_non_blind_parser.parse(input)
  end

  def self.parse_with_simple_inline(input)
    simple_inline_parser.parse(input)
  end

  def self.demonstrate_local_variables
    # Demonstrates local variable usage in parser construction
    pattern_a = str('a')
    pattern_aa = str('aa')
    # Use a simple combination that works reliably
    combined = pattern_aa | pattern_a >> pattern_aa | pattern_a >> pattern_a >> pattern_aa
    combined
  end
end
