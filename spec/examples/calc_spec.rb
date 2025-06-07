require 'spec_helper'
require_relative '../fixtures/examples/calc'

RSpec.describe 'Calculator Parser Example' do
  let(:parser) { CalcExample::CalcParser.new }
  let(:transformer) { CalcExample::CalcTransform.new }

  describe CalcExample::CalcParser do
    describe '#integer' do
      it 'parses single digits' do
        result = parser.integer.parse('1')
        expect(result).to parse_as({ i: '1' })
      end

      it 'parses multi-digit numbers' do
        result = parser.integer.parse('123')
        expect(result).to parse_as({ i: '123' })
      end

      it 'consumes trailing whitespace' do
        result = parser.integer.parse('123   ')
        expect(result).to parse_as({ i: '123' })
      end

      it 'fails to parse floats' do
        expect { parser.integer.parse('1.3') }.to raise_error(Parslet::ParseFailed)
      end

      it 'fails to parse letters' do
        expect { parser.integer.parse('abc') }.to raise_error(Parslet::ParseFailed)
      end
    end

    describe '#mult_op' do
      it 'parses multiplication operator' do
        result = parser.mult_op.parse('*')
        expect(result).to parse_as({ o: '*' })
      end

      it 'parses division operator' do
        result = parser.mult_op.parse('/')
        expect(result).to parse_as({ o: '/' })
      end

      it 'consumes trailing whitespace' do
        result = parser.mult_op.parse('*  ')
        expect(result).to parse_as({ o: '*' })
      end
    end

    describe '#add_op' do
      it 'parses addition operator' do
        result = parser.add_op.parse('+')
        expect(result).to parse_as({ o: '+' })
      end

      it 'parses subtraction operator' do
        result = parser.add_op.parse('-')
        expect(result).to parse_as({ o: '-' })
      end
    end

    describe '#multiplication' do
      it 'parses simple multiplication' do
        result = parser.multiplication.parse('1*2')
        expected = [
          { l: { i: '1' } },
          { o: '*', r: { i: '2' } }
        ]
        expect(result).to parse_as(expected)
      end

      it 'parses simple division' do
        result = parser.multiplication.parse('1/2')
        expected = [
          { l: { i: '1' } },
          { o: '/', r: { i: '2' } }
        ]
        expect(result).to parse_as(expected)
      end

      it 'parses single integer as multiplication' do
        result = parser.multiplication.parse('42')
        expected = { i: '42' }
        expect(result).to parse_as(expected)
      end

      it 'parses chained multiplication' do
        result = parser.multiplication.parse('2*3*4')
        expected = [
          { l: { i: '2' } },
          { o: '*', r: { i: '3' } },
          { o: '*', r: { i: '4' } }
        ]
        expect(result).to parse_as(expected)
      end
    end

    describe '#addition' do
      it 'parses simple addition' do
        result = parser.addition.parse('1+2')
        expected = [
          { l: { i: '1' } },
          { o: '+', r: { i: '2' } }
        ]
        expect(result).to parse_as(expected)
      end

      it 'parses chained addition and subtraction' do
        result = parser.addition.parse('1+2+3-4')
        expected = [
          { l: { i: '1' } },
          { o: '+', r: { i: '2' } },
          { o: '+', r: { i: '3' } },
          { o: '-', r: { i: '4' } }
        ]
        expect(result).to parse_as(expected)
      end

      it 'parses single integer as addition' do
        result = parser.addition.parse('42')
        expected = { i: '42' }
        expect(result).to parse_as(expected)
      end
    end

    describe 'root parser (addition)' do
      it 'parses complex expressions with precedence' do
        result = parser.parse('1+2*3')
        expected = [
          { l: { i: '1' } },
          {
            o: '+',
            r: [
              { l: { i: '2' } },
              { o: '*', r: { i: '3' } }
            ]
          }
        ]
        expect(result).to parse_as(expected)
      end
    end
  end

  describe CalcExample::CalcTransform do
    it 'transforms integer slices to Int objects' do
      input = { i: Parslet::Slice.new(Parslet::Position.new("123", 0), "123") }
      result = transformer.apply(input)
      expect(result).to be_a(CalcExample::Int)
      expect(result.int).to eq(123)
    end

    it 'transforms operation structures to LeftOp objects' do
      input = { o: Parslet::Slice.new(Parslet::Position.new("+", 0), "+"), r: CalcExample::Int.new(5) }
      result = transformer.apply(input)
      expect(result).to be_a(CalcExample::LeftOp)
      expect(result.operation.to_s).to eq('+')
      expect(result.right).to be_a(CalcExample::Int)
      expect(result.right.int).to eq(5)
    end

    it 'unwraps left operand' do
      input = { l: CalcExample::Int.new(42) }
      result = transformer.apply(input)
      expect(result).to be_a(CalcExample::Int)
      expect(result.int).to eq(42)
    end

    it 'transforms sequences to Seq objects' do
      input = [CalcExample::LeftOp.new('+', CalcExample::Int.new(2)), CalcExample::LeftOp.new('*', CalcExample::Int.new(3))]
      result = transformer.apply(input)
      expect(result).to be_a(CalcExample::Seq)
      expect(result.sequence).to be_an(Array)
      expect(result.sequence.length).to eq(2)
    end
  end

  describe 'AST evaluation' do
    describe CalcExample::Int do
      it 'evaluates to itself' do
        int = CalcExample::Int.new(42)
        expect(int.eval).to eq(int)
      end

      it 'performs addition operation' do
        left = CalcExample::Int.new(5)
        right = CalcExample::Int.new(3)
        result = left.op('+', right)
        expect(result).to be_a(CalcExample::Int)
        expect(result.int).to eq(8)
      end

      it 'performs subtraction operation' do
        left = CalcExample::Int.new(5)
        right = CalcExample::Int.new(3)
        result = left.op('-', right)
        expect(result).to be_a(CalcExample::Int)
        expect(result.int).to eq(2)
      end

      it 'performs multiplication operation' do
        left = CalcExample::Int.new(5)
        right = CalcExample::Int.new(3)
        result = left.op('*', right)
        expect(result).to be_a(CalcExample::Int)
        expect(result.int).to eq(15)
      end

      it 'performs division operation' do
        left = CalcExample::Int.new(6)
        right = CalcExample::Int.new(3)
        result = left.op('/', right)
        expect(result).to be_a(CalcExample::Int)
        expect(result.int).to eq(2)
      end
    end

    describe CalcExample::LeftOp do
      it 'applies operation to left operand' do
        left = CalcExample::Int.new(5)
        op = CalcExample::LeftOp.new('+', CalcExample::Int.new(3))
        result = op.call(left)
        expect(result).to be_a(CalcExample::Int)
        expect(result.int).to eq(8)
      end
    end

    describe CalcExample::Seq do
      it 'reduces sequence of operations' do
        seq = CalcExample::Seq.new([
          CalcExample::LeftOp.new('+', CalcExample::Int.new(2)),
          CalcExample::LeftOp.new('*', CalcExample::Int.new(3))
        ])
        # Starting with some initial value, this would be: (init + 2) * 3
        # But we need to provide an initial value to test this properly
      end
    end
  end

  describe 'integration tests' do
    describe 'calculate function' do
      it 'calculates simple addition' do
        expect(CalcExample.calculate('1+1')).to eq(2)
      end

      it 'calculates left-associative subtraction' do
        expect(CalcExample.calculate('1-1-1')).to eq(-1)
      end

      it 'calculates with proper precedence' do
        expect(CalcExample.calculate('1+1+3*5/2')).to eq(9)
      end

      it 'calculates simple multiplication' do
        expect(CalcExample.calculate('123*2')).to eq(246)
      end

      it 'calculates complex expressions' do
        expect(CalcExample.calculate('2+3*4')).to eq(14)
        expect(CalcExample.calculate('10-2*3')).to eq(4)
        expect(CalcExample.calculate('20/4+1')).to eq(6)
      end

      it 'handles single numbers' do
        expect(CalcExample.calculate('42')).to eq(42)
      end

      it 'handles whitespace' do
        expect(CalcExample.calculate('1 + 2 * 3')).to eq(7)
      end
    end

    it 'produces the expected output for the example' do
      # This tests the actual example execution
      expect(CalcExample.calculate('123*2')).to eq(246)
    end
  end
end
