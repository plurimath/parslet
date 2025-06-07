# A simple integer calculator to answer the question about how to do
# left and right associativity in parslet (PEG) once and for all.

require 'parslet'

module CalcExample
  # This is the parsing stage. It expresses left associativity by compiling
  # list of things that have the same associativity.
  class CalcParser < Parslet::Parser
    root :addition

    rule(:addition) {
      multiplication.as(:l) >> (add_op >> multiplication.as(:r)).repeat(1) |
      multiplication
    }

    rule(:multiplication) {
      integer.as(:l) >> (mult_op >> integer.as(:r)).repeat(1) |
      integer }

    rule(:integer) { digit.repeat(1).as(:i) >> space? }

    rule(:mult_op) { match['*/'].as(:o) >> space? }
    rule(:add_op) { match['+-'].as(:o) >> space? }

    rule(:digit) { match['0-9'] }
    rule(:space?) { match['\s'].repeat }
  end

  # Classes for the abstract syntax tree.
  Int = Struct.new(:int) do
    def eval; self end
    def op(operation, other)
      left = int
      right = other.int

      Int.new(
        case operation
          when '+'
            left + right
          when '-'
            left - right
          when '*'
            left * right
          when '/'
            left / right
        end)
    end
    def to_i
      int
    end
  end

  Seq = Struct.new(:sequence) do
    def eval
      sequence.reduce { |accum, operation|
        operation.call(accum) }
    end
  end

  LeftOp = Struct.new(:operation, :right) do
    def call(left)
      left = left.eval
      right = self.right.eval

      left.op(operation, right)
    end
  end

  # Transforming intermediary syntax tree into a real AST.
  class CalcTransform < Parslet::Transform
    rule(i: simple(:i)) { Int.new(Integer(i)) }
    rule(o: simple(:o), r: simple(:i)) { LeftOp.new(o, i) }
    rule(l: simple(:i)) { i }
    rule(sequence(:seq)) { Seq.new(seq) }
  end

  # And this calls everything in the right order.
  def self.calculate(str)
    intermediary_tree = CalcParser.new.parse(str)
    abstract_tree = CalcTransform.new.apply(intermediary_tree)
    result = abstract_tree.eval

    result.to_i
  end
end
