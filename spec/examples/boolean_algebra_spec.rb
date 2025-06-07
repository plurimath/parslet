require 'spec_helper'
require_relative '../fixtures/examples/boolean_algebra'

RSpec.describe 'Boolean Algebra Parser Example' do
  let(:parser) { MyParser.new }
  let(:transformer) { Transformer.new }

  describe MyParser do
    describe '#var' do
      it 'parses variable names' do
        result = parser.var.parse('var1')
        expect(result).to parse_as({ var: '1' })
      end

      it 'parses multi-digit variables' do
        result = parser.var.parse('var123')
        expect(result).to parse_as({ var: '123' })
      end

      it 'handles trailing space' do
        result = parser.var.parse('var1 ')
        expect(result).to parse_as({ var: '1' })
      end
    end

    describe '#primary' do
      it 'parses variables as primary expressions' do
        result = parser.primary.parse('var1')
        expect(result).to parse_as({ var: '1' })
      end

      it 'parses parenthesized expressions' do
        result = parser.primary.parse('(var1)')
        expect(result).to parse_as({ var: '1' })
      end

      it 'parses complex parenthesized expressions' do
        result = parser.primary.parse('(var1 or var2)')
        expected = {
          or: {
            left: { var: '1' },
            right: { var: '2' }
          }
        }
        expect(result).to parse_as(expected)
      end
    end

    describe '#and_operation' do
      it 'parses simple AND operations' do
        result = parser.and_operation.parse('var1 and var2')
        expected = {
          and: {
            left: { var: '1' },
            right: { var: '2' }
          }
        }
        expect(result).to parse_as(expected)
      end

      it 'parses chained AND operations (right-associative)' do
        result = parser.and_operation.parse('var1 and var2 and var3')
        expected = {
          and: {
            left: { var: '1' },
            right: {
              and: {
                left: { var: '2' },
                right: { var: '3' }
              }
            }
          }
        }
        expect(result).to parse_as(expected)
      end

      it 'parses single variables' do
        result = parser.and_operation.parse('var1')
        expect(result).to parse_as({ var: '1' })
      end
    end

    describe '#or_operation' do
      it 'parses simple OR operations' do
        result = parser.or_operation.parse('var1 or var2')
        expected = {
          or: {
            left: { var: '1' },
            right: { var: '2' }
          }
        }
        expect(result).to parse_as(expected)
      end

      it 'parses chained OR operations (right-associative)' do
        result = parser.or_operation.parse('var1 or var2 or var3')
        expected = {
          or: {
            left: { var: '1' },
            right: {
              or: {
                left: { var: '2' },
                right: { var: '3' }
              }
            }
          }
        }
        expect(result).to parse_as(expected)
      end

      it 'handles operator precedence (AND binds tighter than OR)' do
        result = parser.or_operation.parse('var1 or var2 and var3')
        expected = {
          or: {
            left: { var: '1' },
            right: {
              and: {
                left: { var: '2' },
                right: { var: '3' }
              }
            }
          }
        }
        expect(result).to parse_as(expected)
      end
    end

    describe 'root parser (or_operation)' do
      it 'parses the main example: var1 and (var2 or var3)' do
        input = "var1 and (var2 or var3)"
        result = parser.parse(input)
        expected = {
          and: {
            left: { var: '1' },
            right: {
              or: {
                left: { var: '2' },
                right: { var: '3' }
              }
            }
          }
        }
        expect(result).to parse_as(expected)
      end

      it 'handles complex expressions with precedence and parentheses' do
        result = parser.parse('(var1 and var2) or var3')
        expected = {
          or: {
            left: {
              and: {
                left: { var: '1' },
                right: { var: '2' }
              }
            },
            right: { var: '3' }
          }
        }
        expect(result).to parse_as(expected)
      end
    end
  end

  describe Transformer do
    it 'transforms variables to DNF arrays' do
      input = { var: Parslet::Slice.new(Parslet::Position.new("var1", 3), "1") }
      result = transformer.apply(input)
      expect(result).to eq([["1"]])
    end

    it 'transforms OR operations by concatenating arrays' do
      input = {
        or: {
          left: [["1"]],
          right: [["2"]]
        }
      }
      result = transformer.apply(input)
      expect(result).to eq([["1"], ["2"]])
    end

    it 'transforms AND operations by creating cartesian product' do
      input = {
        and: {
          left: [["1"]],
          right: [["2"]]
        }
      }
      result = transformer.apply(input)
      expect(result).to eq([["1", "2"]])
    end

    it 'handles complex AND operations with multiple terms' do
      input = {
        and: {
          left: [["1"], ["2"]],
          right: [["3"]]
        }
      }
      result = transformer.apply(input)
      expect(result).to eq([["1", "3"], ["2", "3"]])
    end

    it 'handles complex OR operations with AND sub-expressions' do
      input = {
        and: {
          left: [["1"]],
          right: [["2"], ["3"]]
        }
      }
      result = transformer.apply(input)
      expect(result).to eq([["1", "2"], ["1", "3"]])
    end
  end

  describe 'integration test' do
    it 'processes the main example correctly: var1 and (var2 or var3)' do
      input = "var1 and (var2 or var3)"
      tree = parser.parse(input)
      result = transformer.apply(tree)

      # Expected result: [["1", "2"], ["1", "3"]]
      # This represents: (var1 AND var2) OR (var1 AND var3)
      expect(result).to eq([["1", "2"], ["1", "3"]])
    end

    it 'handles simple OR expressions' do
      input = "var1 or var2"
      tree = parser.parse(input)
      result = transformer.apply(tree)
      expect(result).to eq([["1"], ["2"]])
    end

    it 'handles simple AND expressions' do
      input = "var1 and var2"
      tree = parser.parse(input)
      result = transformer.apply(tree)
      expect(result).to eq([["1", "2"]])
    end

    it 'handles complex expressions with multiple operators' do
      input = "(var1 or var2) and (var3 or var4)"
      tree = parser.parse(input)
      result = transformer.apply(tree)
      # Should produce: [["1", "3"], ["1", "4"], ["2", "3"], ["2", "4"]]
      expect(result).to eq([["1", "3"], ["1", "4"], ["2", "3"], ["2", "4"]])
    end

    it 'produces the expected output from the example file' do
      # This matches the exact output shown in the example file
      input = "var1 and (var2 or var3)"
      tree = parser.parse(input)
      result = transformer.apply(tree)
      expect(result).to eq([["1", "2"], ["1", "3"]])
    end
  end
end
