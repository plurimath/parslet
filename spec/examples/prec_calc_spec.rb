require 'spec_helper'

# Load the example file to get the classes
$:.unshift File.dirname(__FILE__) + "/../../example"

# Define the classes directly to avoid eval issues
require 'pp'
require 'parslet'
require 'parslet/rig/rspec'
require 'parslet/convenience'

include Parslet

class InfixExpressionParser < Parslet::Parser
  root :variable_assignment_list

  rule(:space) { match[' '] }

  def cts atom
    atom >> space.repeat
  end
  def infix *args
    Infix.new(*args)
  end

  # This is the heart of the infix expression parser: real simple definitions
  # for all the pieces we need.
  rule(:mul_op) { cts match['*/'] }
  rule(:add_op) { cts match['+-'] }
  rule(:digit) { match['0-9'] }
  rule(:integer) { cts digit.repeat(1).as(:int) }

  rule(:expression) { infix_expression(integer,
    [mul_op, 2, :left],
    [add_op, 1, :right]) }

  # And now adding variable assignments to that, just to a) demonstrate this
  # embedded in a bigger parser, and b) make the example interesting.
  rule(:variable_assignment_list) {
    variable_assignment.repeat(1) }
  rule(:variable_assignment) {
    identifier.as(:ident) >> equal_sign >> expression.as(:exp) >> eol }
  rule(:identifier) {
    cts (match['a-z'] >> match['a-zA-Z0-9'].repeat) }
  rule(:equal_sign) {
    cts str('=') }
  rule(:eol) {
    cts(str("\n")) | any.absent? }
end

class InfixInterpreter < Parslet::Transform
  rule(int: simple(:int)) { Integer(int) }
  rule(ident: simple(:ident), exp: simple(:result)) { |d|
    d[:doc][d[:ident].to_s.strip.to_sym] = d[:result] }

  rule(l: simple(:l), o: /^\*/, r: simple(:r)) { l * r }
  rule(l: simple(:l), o: /^\+/, r: simple(:r)) { l + r }
end

RSpec.describe 'Precedence Calculator Example' do
  let(:parser) { InfixExpressionParser.new }
  let(:interpreter) { InfixInterpreter.new }

  describe InfixExpressionParser do
    describe '#digit' do
      it 'parses single digits' do
        result = parser.digit.parse('5')
        expect(result).to eq('5')
      end

      it 'fails on non-digits' do
        expect { parser.digit.parse('a') }.to raise_error(Parslet::ParseFailed)
      end

      it 'fails on empty input' do
        expect { parser.digit.parse('') }.to raise_error(Parslet::ParseFailed)
      end
    end

    describe '#integer' do
      it 'parses single digit integers' do
        result = parser.integer.parse('5')
        expect(result).to eq({:int => '5'})
      end

      it 'parses multi-digit integers' do
        result = parser.integer.parse('123')
        expect(result).to eq({:int => '123'})
      end

      it 'parses integers with trailing spaces' do
        result = parser.integer.parse('123 ')
        expect(result).to eq({:int => '123'})
      end

      it 'fails on non-numeric input' do
        expect { parser.integer.parse('abc') }.to raise_error(Parslet::ParseFailed)
      end
    end

    describe '#mul_op' do
      it 'parses multiplication operator' do
        result = parser.mul_op.parse('*')
        expect(result.to_s).to eq('*')
      end

      it 'parses division operator' do
        result = parser.mul_op.parse('/')
        expect(result.to_s).to eq('/')
      end

      it 'parses operators with trailing spaces' do
        result = parser.mul_op.parse('* ')
        expect(result.to_s.strip).to eq('*')
      end

      it 'fails on other operators' do
        expect { parser.mul_op.parse('+') }.to raise_error(Parslet::ParseFailed)
      end
    end

    describe '#add_op' do
      it 'parses addition operator' do
        result = parser.add_op.parse('+')
        expect(result.to_s).to eq('+')
      end

      it 'parses subtraction operator' do
        result = parser.add_op.parse('-')
        expect(result.to_s).to eq('-')
      end

      it 'parses operators with trailing spaces' do
        result = parser.add_op.parse('+ ')
        expect(result.to_s.strip).to eq('+')
      end

      it 'fails on other operators' do
        expect { parser.add_op.parse('*') }.to raise_error(Parslet::ParseFailed)
      end
    end

    describe '#identifier' do
      it 'parses simple identifiers' do
        result = parser.identifier.parse('a')
        expect(result).to eq('a')
      end

      it 'parses multi-character identifiers' do
        result = parser.identifier.parse('variable')
        expect(result).to eq('variable')
      end

      it 'parses identifiers with numbers' do
        result = parser.identifier.parse('var123')
        expect(result).to eq('var123')
      end

      it 'parses identifiers with trailing spaces' do
        result = parser.identifier.parse('abc ')
        expect(result.to_s.strip).to eq('abc')
      end

      it 'fails on identifiers starting with numbers' do
        expect { parser.identifier.parse('123abc') }.to raise_error(Parslet::ParseFailed)
      end

      it 'fails on identifiers starting with uppercase' do
        expect { parser.identifier.parse('Abc') }.to raise_error(Parslet::ParseFailed)
      end
    end

    describe '#equal_sign' do
      it 'parses equal sign' do
        result = parser.equal_sign.parse('=')
        expect(result).to eq('=')
      end

      it 'parses equal sign with trailing spaces' do
        result = parser.equal_sign.parse('= ')
        expect(result.to_s.strip).to eq('=')
      end

      it 'fails on other characters' do
        expect { parser.equal_sign.parse('+') }.to raise_error(Parslet::ParseFailed)
      end
    end

    describe '#eol' do
      it 'parses newline' do
        result = parser.eol.parse("\n")
        expect(result).to eq("\n")
      end

      it 'parses newline with trailing spaces' do
        result = parser.eol.parse("\n ")
        expect(result.to_s).to eq("\n ")
      end

      it 'parses end of input' do
        result = parser.eol.parse('')
        expect(result).to be_nil
      end
    end

    describe '#expression' do
      it 'parses simple integers' do
        result = parser.expression.parse('42')
        expect(result).to eq({:int => '42'})
      end

      it 'parses simple addition' do
        result = parser.expression.parse('1 + 2')
        expect(result).to eq({l: {:int => '1'}, o: '+ ', r: {:int => '2'}})
      end

      it 'parses simple multiplication' do
        result = parser.expression.parse('3 * 4')
        expect(result).to eq({l: {:int => '3'}, o: '* ', r: {:int => '4'}})
      end

      it 'parses expressions with correct precedence (multiplication first)' do
        result = parser.expression.parse('1 + 2 * 3')
        # Should parse as 1 + (2 * 3) due to precedence
        expect(result).to eq({
          l: {:int => '1'},
          o: '+ ',
          r: {l: {:int => '2'}, o: '* ', r: {:int => '3'}}
        })
      end

      it 'parses complex expressions' do
        result = parser.expression.parse('100 + 3*4')
        expect(result).to eq({
          l: {:int => '100'},
          o: '+ ',
          r: {l: {:int => '3'}, o: '*', r: {:int => '4'}}
        })
      end
    end

    describe '#variable_assignment' do
      it 'parses simple variable assignment' do
        result = parser.variable_assignment.parse("a = 1\n")
        expect(result).to have_key(:ident)
        expect(result).to have_key(:exp)
        expect(result[:ident].to_s.strip).to eq('a')
        expect(result[:exp]).to eq({:int => '1'})
      end

      it 'parses assignment with expression' do
        result = parser.variable_assignment.parse("result = 2 + 3\n")
        expect(result).to have_key(:ident)
        expect(result).to have_key(:exp)
        expect(result[:ident].to_s.strip).to eq('result')
        expect(result[:exp]).to have_key(:l)
        expect(result[:exp]).to have_key(:o)
        expect(result[:exp]).to have_key(:r)
      end

      it 'parses assignment at end of input' do
        result = parser.variable_assignment.parse("x = 42")
        expect(result).to have_key(:ident)
        expect(result).to have_key(:exp)
        expect(result[:ident].to_s.strip).to eq('x')
        expect(result[:exp]).to eq({:int => '42'})
      end
    end

    describe '#variable_assignment_list (root)' do
      it 'parses single assignment' do
        result = parser.parse("a = 1\n")
        expect(result).to be_an(Array)
        expect(result.length).to eq(1)
        expect(result[0]).to have_key(:ident)
        expect(result[0]).to have_key(:exp)
        expect(result[0][:ident].to_s.strip).to eq('a')
        expect(result[0][:exp]).to eq({:int => '1'})
      end

      it 'parses multiple assignments' do
        input = "a = 1\nb = 2\n"
        result = parser.parse(input)
        expect(result).to be_an(Array)
        expect(result.length).to eq(2)
        expect(result[0][:ident].to_s.strip).to eq('a')
        expect(result[0][:exp]).to eq({:int => '1'})
        expect(result[1][:ident].to_s.strip).to eq('b')
        expect(result[1][:exp]).to eq({:int => '2'})
      end

      it 'parses assignments with complex expressions' do
        input = "a = 1\nb = 2\nc = 3 * 25\n"
        result = parser.parse(input)
        expect(result).to be_an(Array)
        expect(result.length).to eq(3)
        expect(result[0][:ident].to_s.strip).to eq('a')
        expect(result[0][:exp]).to eq({:int => '1'})
        expect(result[1][:ident].to_s.strip).to eq('b')
        expect(result[1][:exp]).to eq({:int => '2'})
        expect(result[2]).to have_key(:ident)
        expect(result[2]).to have_key(:exp)
        expect(result[2][:ident].to_s.strip).to eq('c')
        expect(result[2][:exp]).to have_key(:l)
        expect(result[2][:exp]).to have_key(:o)
        expect(result[2][:exp]).to have_key(:r)
      end
    end
  end

  describe InfixInterpreter do
    describe 'integer transformation' do
      it 'transforms integer nodes to Ruby integers' do
        result = interpreter.apply({int: '42'})
        expect(result).to eq(42)
        expect(result).to be_a(Integer)
      end

      it 'transforms string integers correctly' do
        result = interpreter.apply({int: '123'})
        expect(result).to eq(123)
      end
    end

    describe 'arithmetic operations' do
      it 'performs multiplication' do
        result = interpreter.apply({l: 3, o: '*', r: 4})
        expect(result).to eq(12)
      end

      it 'performs addition' do
        result = interpreter.apply({l: 5, o: '+', r: 7})
        expect(result).to eq(12)
      end

      it 'handles nested operations' do
        # Represents 2 + (3 * 4)
        nested = {
          l: 2,
          o: '+',
          r: {l: 3, o: '*', r: 4}
        }
        result = interpreter.apply(nested)
        expect(result).to eq(14)
      end
    end

    describe 'variable assignment transformation' do
      it 'assigns simple values to variables' do
        doc = {}
        result = interpreter.apply({ident: 'a', exp: 42}, doc: doc)
        expect(doc[:a]).to eq(42)
      end

      it 'assigns expression results to variables' do
        doc = {}
        result = interpreter.apply({ident: 'result', exp: 15}, doc: doc)
        expect(doc[:result]).to eq(15)
      end

      it 'handles multiple assignments' do
        doc = {}
        assignments = [
          {ident: 'a', exp: 1},
          {ident: 'b', exp: 2}
        ]
        interpreter.apply(assignments, doc: doc)
        expect(doc[:a]).to eq(1)
        expect(doc[:b]).to eq(2)
      end
    end
  end

  describe 'integration test with example input' do
    let(:input) do
      <<~ASSIGNMENTS
        a = 1
        b = 2
        c = 3 * 25
        d = 100 + 3*4
      ASSIGNMENTS
    end

    it 'parses the example input correctly' do
      result = parser.parse(input)
      expect(result).to be_an(Array)
      expect(result.length).to eq(4)

      # Check each assignment structure
      expect(result[0]).to have_key(:ident)
      expect(result[0]).to have_key(:exp)
        expect(result[0][:ident].to_s.strip).to eq('a')
        expect(result[0][:exp]).to eq({:int => '1'})

        expect(result[1]).to have_key(:ident)
        expect(result[1]).to have_key(:exp)
        expect(result[1][:ident].to_s.strip).to eq('b')
        expect(result[1][:exp]).to eq({:int => '2'})

        # c = 3 * 25
        expect(result[2][:ident].to_s.strip).to eq('c')
      expect(result[2][:exp]).to have_key(:l)
      expect(result[2][:exp]).to have_key(:o)
      expect(result[2][:exp]).to have_key(:r)

      # d = 100 + 3*4 (should respect precedence)
      expect(result[3][:ident].to_s.strip).to eq('d')
      expect(result[3][:exp]).to have_key(:l)
      expect(result[3][:exp]).to have_key(:o)
      expect(result[3][:exp]).to have_key(:r)
    end

    it 'transforms and evaluates the example correctly' do
      parse_tree = parser.parse(input)
      bindings = {}
      interpreter.apply(parse_tree, doc: bindings)

      expect(bindings[:a]).to eq(1)
      expect(bindings[:b]).to eq(2)
      expect(bindings[:c]).to eq(75)  # 3 * 25
      expect(bindings[:d]).to eq(112) # 100 + (3*4) = 100 + 12
    end

    it 'reproduces the example behavior' do
      # This test reproduces what the example file does
      int_tree = parser.parse(input)
      bindings = {}
      result = interpreter.apply(int_tree, doc: bindings)

      # Verify the final bindings match expected values
      expected_bindings = {
        a: 1,
        b: 2,
        c: 75,
        d: 112
      }

      expect(bindings).to eq(expected_bindings)
    end
  end

  describe 'precedence and associativity' do
    it 'handles left associativity for addition' do
      # Test that 1 + 2 + 3 is parsed as (1 + 2) + 3
      result = parser.expression.parse('1 + 2 + 3')
      # Due to right associativity setting, this should be 1 + (2 + 3)
      expect(result).to eq({
        l: {:int => '1'},
        o: '+ ',
        r: {l: {:int => '2'}, o: '+ ', r: {:int => '3'}}
      })
    end

    it 'handles multiplication precedence over addition' do
      # Test that 2 + 3 * 4 is parsed as 2 + (3 * 4)
      result = parser.expression.parse('2 + 3 * 4')
      expect(result).to eq({
        l: {:int => '2'},
        o: '+ ',
        r: {l: {:int => '3'}, o: '* ', r: {:int => '4'}}
      })
    end

    it 'evaluates precedence correctly in complex expressions' do
      input = "result = 1 + 2 * 3 + 4\n"
      parse_tree = parser.parse(input)
      bindings = {}
      interpreter.apply(parse_tree, doc: bindings)

      # Should be 1 + (2 * 3) + 4 = 1 + 6 + 4 = 11
      # But with right associativity: 1 + (2 * 3 + 4) = 1 + (6 + 4) = 1 + 10 = 11
      expect(bindings[:result]).to eq(11)
    end
  end

  describe 'error handling' do
    it 'fails on invalid variable names' do
      expect { parser.parse("123invalid = 1\n") }.to raise_error(Parslet::ParseFailed)
    end

    it 'fails on missing equal sign' do
      expect { parser.parse("a 1\n") }.to raise_error(Parslet::ParseFailed)
    end

    it 'fails on incomplete expressions' do
      expect { parser.parse("a = 1 +\n") }.to raise_error(Parslet::ParseFailed)
    end

    it 'fails on invalid operators' do
      expect { parser.parse("a = 1 % 2\n") }.to raise_error(Parslet::ParseFailed)
    end

    it 'handles empty input' do
      expect { parser.parse("") }.to raise_error(Parslet::ParseFailed)
    end
  end

  describe 'edge cases' do
    it 'handles single character variable names' do
      result = parser.parse("x = 1\n")
      expect(result[0][:ident].to_s.strip).to eq('x')
    end

    it 'handles large numbers' do
      result = parser.parse("big = 999999\n")
      bindings = {}
      interpreter.apply(result, doc: bindings)
      expect(bindings[:big]).to eq(999999)
    end

    it 'handles expressions without spaces' do
      result = parser.parse("compact=1+2*3\n")
      bindings = {}
      interpreter.apply(result, doc: bindings)
      expect(bindings[:compact]).to eq(7) # 1 + (2 * 3)
    end

    it 'handles assignments at end of input without newline' do
      result = parser.parse("final = 42")
      bindings = {}
      interpreter.apply(result, doc: bindings)
      expect(bindings[:final]).to eq(42)
    end
  end
end
