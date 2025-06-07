# Example that demonstrates how a simple erb-like parser could be constructed.

require 'parslet'

class ErbParser < Parslet::Parser
  rule(:ruby) { (str('%>').absent? >> any).repeat.as(:ruby) }

  rule(:expression) { (str('=') >> ruby).as(:expression) }
  rule(:comment) { (str('#') >> ruby).as(:comment) }
  rule(:code) { ruby.as(:code) }
  rule(:erb) { expression | comment | code }

  rule(:erb_with_tags) { str('<%') >> erb >> str('%>') }
  rule(:text) { (str('<%').absent? >> any).repeat(1) }

  rule(:text_with_ruby) { (text.as(:text) | erb_with_tags).repeat.as(:text) }
  root(:text_with_ruby)
end

class ErbTransform < Parslet::Transform
  def initialize(binding_context = binding)
    super()
    @erb_binding = binding_context

    # Define rules with closures that capture the binding
    rule(:code => { :ruby => simple(:ruby) }) do |dict|
      eval(dict[:ruby].to_s, @erb_binding)
      ''
    end

    rule(:expression => { :ruby => simple(:ruby) }) do |dict|
      eval(dict[:ruby].to_s, @erb_binding)
    end
  end

  rule(:comment => { :ruby => simple(:ruby) }) { '' }
  rule(:text => simple(:text)) { text }
  rule(:text => sequence(:texts)) { texts.join }
end
