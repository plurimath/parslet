require 'spec_helper'
require_relative '../fixtures/examples/parens'

RSpec.describe 'Parens Example' do
  let(:parser) { LISP::Parser.new }
  let(:transform) { LISP::Transform.new }

  describe LISP::Parser do
    describe '#balanced (root)' do
      it 'parses empty parentheses' do
        result = parser.parse('()')
        expected = {
          l: '(',
          m: nil,
          r: ')'
        }
        expect(result).to parse_as(expected)
      end

      it 'parses nested parentheses' do
        result = parser.parse('(())')
        expected = {
          l: '(',
          m: {
            l: '(',
            m: nil,
            r: ')'
          },
          r: ')'
        }
        expect(result).to parse_as(expected)
      end

      it 'parses deeply nested parentheses' do
        result = parser.parse('((((()))))')
        expected = {
          l: '(',
          m: {
            l: '(',
            m: {
              l: '(',
              m: {
                l: '(',
                m: {
                  l: '(',
                  m: nil,
                  r: ')'
                },
                r: ')'
              },
              r: ')'
            },
            r: ')'
          },
          r: ')'
        }
        expect(result).to parse_as(expected)
      end

      it 'fails on unbalanced parentheses' do
        expect { parser.parse('((())') }.to raise_error(Parslet::ParseFailed)
      end

      it 'fails on mismatched parentheses' do
        expect { parser.parse('()(') }.to raise_error(Parslet::ParseFailed)
      end

      it 'fails on extra closing parentheses' do
        expect { parser.parse('())') }.to raise_error(Parslet::ParseFailed)
      end

      it 'fails on just opening parenthesis' do
        expect { parser.parse('(') }.to raise_error(Parslet::ParseFailed)
      end

      it 'fails on just closing parenthesis' do
        expect { parser.parse(')') }.to raise_error(Parslet::ParseFailed)
      end

      it 'fails on empty string' do
        expect { parser.parse('') }.to raise_error(Parslet::ParseFailed)
      end

      it 'parses triple nested parentheses' do
        result = parser.parse('((()))')
        expected = {
          l: '(',
          m: {
            l: '(',
            m: {
              l: '(',
              m: nil,
              r: ')'
            },
            r: ')'
          },
          r: ')'
        }
        expect(result).to parse_as(expected)
      end
    end
  end

  describe LISP::Transform do
    describe 'counting parentheses levels' do
      it 'counts single level as 1' do
        tree = { l: '(', m: nil, r: ')' }
        result = transform.apply(tree)
        expect(result).to eq(1)
      end

      it 'counts two levels as 2' do
        tree = {
          l: '(',
          m: { l: '(', m: nil, r: ')' },
          r: ')'
        }
        result = transform.apply(tree)
        expect(result).to eq(2)
      end

      it 'counts three levels as 3' do
        tree = {
          l: '(',
          m: {
            l: '(',
            m: { l: '(', m: nil, r: ')' },
            r: ')'
          },
          r: ')'
        }
        result = transform.apply(tree)
        expect(result).to eq(3)
      end

      it 'counts five levels as 5' do
        tree = {
          l: '(',
          m: {
            l: '(',
            m: {
              l: '(',
              m: {
                l: '(',
                m: { l: '(', m: nil, r: ')' },
                r: ')'
              },
              r: ')'
            },
            r: ')'
          },
          r: ')'
        }
        result = transform.apply(tree)
        expect(result).to eq(5)
      end
    end
  end

  describe 'integration tests' do
    it 'processes () correctly' do
      tree = parser.parse('()')
      count = transform.apply(tree)
      expect(count).to eq(1)
    end

    it 'processes (()) correctly' do
      tree = parser.parse('(())')
      count = transform.apply(tree)
      expect(count).to eq(2)
    end

    it 'processes (((((()))))) correctly' do
      tree = parser.parse('((((()))))')
      count = transform.apply(tree)
      expect(count).to eq(5)
    end

    it 'fails on unbalanced ((()) correctly' do
      expect { parser.parse('((())') }.to raise_error(Parslet::ParseFailed, /Failed to match/)
    end

    it 'produces the expected outputs from the example file' do
      # Test case 1: ()
      tree1 = parser.parse('()')
      expected1 = { l: '(', m: nil, r: ')' }
      expect(tree1).to parse_as(expected1)
      expect(transform.apply(tree1)).to eq(1)

      # Test case 2: (())
      tree2 = parser.parse('(())')
      expected2 = {
        l: '(',
        m: { l: '(', m: nil, r: ')' },
        r: ')'
      }
      expect(tree2).to parse_as(expected2)
      expect(transform.apply(tree2)).to eq(2)

      # Test case 3: (((((())))))
      tree3 = parser.parse('((((()))))')
      expected3 = {
        l: '(',
        m: {
          l: '(',
          m: {
            l: '(',
            m: {
              l: '(',
              m: { l: '(', m: nil, r: ')' },
              r: ')'
            },
            r: ')'
          },
          r: ')'
        },
        r: ')'
      }
      expect(tree3).to parse_as(expected3)
      expect(transform.apply(tree3)).to eq(5)

      # Test case 4: ((()) - should fail
      expect { parser.parse('((())') }.to raise_error(Parslet::ParseFailed)
    end

    it 'demonstrates the power of tree pattern matching' do
      # Simple case
      simple_tree = parser.parse('()')
      expect(transform.apply(simple_tree)).to eq(1)

      # Complex nested case
      complex_tree = parser.parse('(((())))')
      expect(transform.apply(complex_tree)).to eq(4)

      # The transform correctly counts nesting levels
      # by recursively applying the rule that adds 1 for each level
    end
  end
end
