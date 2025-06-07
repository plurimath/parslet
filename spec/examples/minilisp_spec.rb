require 'spec_helper'
require_relative '../fixtures/examples/minilisp'

RSpec.describe 'MiniLisp Parser Example' do
  let(:parser) { MiniLisp::Parser.new }
  let(:transform) { MiniLisp::Transform.new }

  describe MiniLisp::Parser do
    describe '#space' do
      it 'parses single space' do
        result = parser.space.parse(' ')
        expect(result).to eq(' ')
      end

      it 'parses multiple spaces' do
        result = parser.space.parse('   ')
        expect(result).to eq('   ')
      end

      it 'parses tabs and newlines' do
        result = parser.space.parse("\t\n ")
        expect(result).to eq("\t\n ")
      end

      it 'fails on empty string' do
        expect { parser.space.parse('') }.to raise_error(Parslet::ParseFailed)
      end
    end

    describe '#space?' do
      it 'parses optional space' do
        result = parser.space?.parse(' ')
        expect(result).to eq(' ')
      end

      it 'parses empty string' do
        result = parser.space?.parse('')
        expect(result).to eq('')
      end

      it 'parses multiple spaces' do
        result = parser.space?.parse('   ')
        expect(result).to eq('   ')
      end
    end

    describe '#identifier' do
      it 'parses simple identifier' do
        result = parser.identifier.parse('test')
        expected = { identifier: 'test' }
        expect(result).to parse_as(expected)
      end

      it 'parses identifier with underscores' do
        result = parser.identifier.parse('test_var')
        expected = { identifier: 'test_var' }
        expect(result).to parse_as(expected)
      end

      it 'parses identifier with equals' do
        result = parser.identifier.parse('=')
        expected = { identifier: '=' }
        expect(result).to parse_as(expected)
      end

      it 'parses identifier with asterisk' do
        result = parser.identifier.parse('*global*')
        expected = { identifier: '*global*' }
        expect(result).to parse_as(expected)
      end

      it 'parses identifier with trailing space' do
        result = parser.identifier.parse('test ')
        expected = { identifier: 'test' }
        expect(result).to parse_as(expected)
      end

      it 'parses mixed case identifier' do
        result = parser.identifier.parse('TestVar')
        expected = { identifier: 'TestVar' }
        expect(result).to parse_as(expected)
      end

      it 'fails on identifier starting with number' do
        expect { parser.identifier.parse('1test') }.to raise_error(Parslet::ParseFailed)
      end

      it 'fails on empty string' do
        expect { parser.identifier.parse('') }.to raise_error(Parslet::ParseFailed)
      end
    end

    describe '#integer' do
      it 'parses positive integer' do
        result = parser.integer.parse('123')
        expected = { integer: '123' }
        expect(result).to parse_as(expected)
      end

      it 'parses negative integer' do
        result = parser.integer.parse('-123')
        expected = { integer: '-123' }
        expect(result).to parse_as(expected)
      end

      it 'parses integer with plus sign' do
        result = parser.integer.parse('+123')
        expected = { integer: '+123' }
        expect(result).to parse_as(expected)
      end

      it 'parses single digit' do
        result = parser.integer.parse('5')
        expected = { integer: '5' }
        expect(result).to parse_as(expected)
      end

      it 'parses zero' do
        result = parser.integer.parse('0')
        expected = { integer: '0' }
        expect(result).to parse_as(expected)
      end

      it 'parses integer with trailing space' do
        result = parser.integer.parse('123 ')
        expected = { integer: '123' }
        expect(result).to parse_as(expected)
      end

      it 'fails on empty string' do
        expect { parser.integer.parse('') }.to raise_error(Parslet::ParseFailed)
      end

      it 'fails on just sign' do
        expect { parser.integer.parse('+') }.to raise_error(Parslet::ParseFailed)
      end
    end

    describe '#float' do
      it 'parses decimal float' do
        result = parser.float.parse('123.45')
        expected = { float: { integer: '123', e: '.45' } }
        expect(result).to parse_as(expected)
      end

      it 'parses scientific notation' do
        result = parser.float.parse('123e45')
        expected = { float: { integer: '123', e: 'e45' } }
        expect(result).to parse_as(expected)
      end

      it 'parses negative float' do
        result = parser.float.parse('-123.45')
        expected = { float: { integer: '-123', e: '.45' } }
        expect(result).to parse_as(expected)
      end

      it 'parses float with plus sign' do
        result = parser.float.parse('+123.45')
        expected = { float: { integer: '+123', e: '.45' } }
        expect(result).to parse_as(expected)
      end

      it 'parses float with trailing space' do
        result = parser.float.parse('123.45 ')
        expected = { float: { integer: '123', e: '.45' } }
        expect(result).to parse_as(expected)
      end

      it 'parses zero float' do
        result = parser.float.parse('0.0')
        expected = { float: { integer: '0', e: '.0' } }
        expect(result).to parse_as(expected)
      end

      it 'fails on integer without decimal part' do
        expect { parser.float.parse('123') }.to raise_error(Parslet::ParseFailed)
      end

      it 'fails on decimal point without digits' do
        expect { parser.float.parse('123.') }.to raise_error(Parslet::ParseFailed)
      end
    end

    describe '#string' do
      it 'parses simple string' do
        result = parser.string.parse('"hello"')
        expected = { string: 'hello' }
        expect(result).to parse_as(expected)
      end

      it 'parses empty string' do
        result = parser.string.parse('""')
        expected = { string: [] }
        expect(result).to parse_as(expected)
      end

      it 'parses string with spaces' do
        result = parser.string.parse('"hello world"')
        expected = { string: 'hello world' }
        expect(result).to parse_as(expected)
      end

      it 'parses string with trailing space' do
        result = parser.string.parse('"hello" ')
        expected = { string: 'hello' }
        expect(result).to parse_as(expected)
      end

      it 'parses string with numbers' do
        result = parser.string.parse('"test123"')
        expected = { string: 'test123' }
        expect(result).to parse_as(expected)
      end

      it 'fails on unclosed string' do
        expect { parser.string.parse('"hello') }.to raise_error(Parslet::ParseFailed)
      end

      it 'fails on string without opening quote' do
        expect { parser.string.parse('hello"') }.to raise_error(Parslet::ParseFailed)
      end
    end

    describe '#body' do
      it 'parses single identifier' do
        result = parser.body.parse('test')
        expected = { exp: [{ identifier: 'test' }] }
        expect(result).to parse_as(expected)
      end

      it 'parses multiple identifiers' do
        result = parser.body.parse('test var')
        expected = { exp: [{ identifier: 'test' }, { identifier: 'var' }] }
        expect(result).to parse_as(expected)
      end

      it 'parses mixed types' do
        result = parser.body.parse('test 123 "hello"')
        expected = {
          exp: [
            { identifier: 'test' },
            { integer: '123' },
            { string: 'hello' }
          ]
        }
        expect(result).to parse_as(expected)
      end

      it 'parses nested expression' do
        result = parser.body.parse('(test)')
        expected = {
          exp: [
            { exp: [{ identifier: 'test' }] }
          ]
        }
        expect(result).to parse_as(expected)
      end

      it 'parses empty body' do
        result = parser.body.parse('')
        expected = { exp: [] }
        expect(result).to parse_as(expected)
      end
    end

    describe '#expression (root)' do
      it 'parses simple expression' do
        result = parser.parse('(test)')
        expected = { exp: [{ identifier: 'test' }] }
        expect(result).to parse_as(expected)
      end

      it 'parses expression with string' do
        result = parser.parse('(display "hello")')
        expected = {
          exp: [
            { identifier: 'display' },
            { string: 'hello' }
          ]
        }
        expect(result).to parse_as(expected)
      end

      it 'parses empty expression' do
        result = parser.parse('()')
        expected = { exp: [] }
        expect(result).to parse_as(expected)
      end

      it 'handles whitespace around expression' do
        result = parser.parse('  ( test )  ')
        expected = { exp: [{ identifier: 'test' }] }
        expect(result).to parse_as(expected)
      end

      it 'fails on unclosed expression' do
        expect { parser.parse('(test') }.to raise_error(Parslet::ParseFailed)
      end

      it 'fails on expression without opening paren' do
        expect { parser.parse('test)') }.to raise_error(Parslet::ParseFailed)
      end

      it 'fails on mismatched parens' do
        expect { parser.parse('(test))') }.to raise_error(Parslet::ParseFailed)
      end
    end

    describe 'error handling' do
      it 'provides meaningful error for invalid syntax' do
        expect { parser.parse('(test invalid@symbol)') }.to raise_error(Parslet::ParseFailed)
      end

      it 'handles unclosed strings in expressions' do
        expect { parser.parse('(test "unclosed)') }.to raise_error(Parslet::ParseFailed)
      end
    end
  end

  describe MiniLisp::Transform do
    describe 'identifier transformation' do
      it 'transforms identifier to symbol' do
        parsed = { identifier: 'test' }
        result = transform.do(parsed)
        expect(result).to eq(:test)
      end

      it 'transforms special identifiers' do
        parsed = { identifier: '+' }
        result = transform.do(parsed)
        expect(result).to eq(:+)
      end

      it 'transforms identifier with underscores' do
        parsed = { identifier: 'test_var' }
        result = transform.do(parsed)
        expect(result).to eq(:test_var)
      end
    end

    describe 'string transformation' do
      it 'transforms string to string' do
        parsed = { string: 'hello' }
        result = transform.do(parsed)
        expect(result).to eq('hello')
      end

      it 'transforms empty string' do
        parsed = { string: [] }
        result = transform.do(parsed)
        expect(result).to eq({ string: [] })
      end

      it 'transforms string with spaces' do
        parsed = { string: 'hello world' }
        result = transform.do(parsed)
        expect(result).to eq('hello world')
      end
    end

    describe 'integer transformation' do
      it 'transforms positive integer' do
        parsed = { integer: '123' }
        result = transform.do(parsed)
        expect(result).to eq(123)
      end

      it 'transforms negative integer' do
        parsed = { integer: '-123' }
        result = transform.do(parsed)
        expect(result).to eq(-123)
      end

      it 'transforms zero' do
        parsed = { integer: '0' }
        result = transform.do(parsed)
        expect(result).to eq(0)
      end

      it 'transforms integer with plus sign' do
        parsed = { integer: '+123' }
        result = transform.do(parsed)
        expect(result).to eq(123)
      end
    end

    describe 'float transformation' do
      it 'transforms decimal float' do
        parsed = { float: { integer: '123', e: '.45' } }
        result = transform.do(parsed)
        expect(result).to eq(123.45)
      end

      it 'transforms scientific notation' do
        parsed = { float: { integer: '123', e: 'e45' } }
        result = transform.do(parsed)
        expect(result).to eq(123e45)
      end

      it 'transforms negative float' do
        parsed = { float: { integer: '-123', e: '.45' } }
        result = transform.do(parsed)
        expect(result).to eq(-123.45)
      end

      it 'transforms zero float' do
        parsed = { float: { integer: '0', e: '.0' } }
        result = transform.do(parsed)
        expect(result).to eq(0.0)
      end
    end

    describe 'expression transformation' do
      it 'transforms expression list' do
        parsed = { exp: [{ identifier: 'test' }, { integer: '123' }] }
        result = transform.do(parsed)
        expect(result).to eq([:test, 123])
      end

      it 'transforms empty expression' do
        parsed = { exp: [] }
        result = transform.do(parsed)
        expect(result).to eq([])
      end

      it 'transforms nested expressions' do
        parsed = {
          exp: [
            { identifier: 'display' },
            { exp: [{ identifier: 'test' }] }
          ]
        }
        result = transform.do(parsed)
        expect(result).to eq([:display, [:test]])
      end
    end

    describe 'integration transformation' do
      it 'transforms function call with string' do
        input = '(display "hello world")'
        parsed = parser.parse(input)
        result = transform.do(parsed)
        expect(result).to eq([:display, "hello world"])
      end

      it 'transforms simple function call' do
        input = '(test)'
        parsed = parser.parse(input)
        result = transform.do(parsed)
        expect(result).to eq([:test])
      end

      it 'transforms nested function calls' do
        input = '(outer (inner))'
        parsed = parser.parse(input)
        result = transform.do(parsed)
        expect(result).to eq([:outer, [:inner]])
      end
    end
  end

  describe 'parser and transformer integration' do
    it 'processes simple lisp expression end-to-end' do
      input = '(test)'
      parsed = parser.parse(input)
      result = transform.do(parsed)
      expect(result).to eq([:test])
    end

    it 'processes function call with string end-to-end' do
      input = '(display "hello")'
      parsed = parser.parse(input)
      result = transform.do(parsed)
      expect(result).to eq([:display, "hello"])
    end

    it 'processes nested expressions end-to-end' do
      input = '(outer (inner "value"))'
      parsed = parser.parse(input)
      result = transform.do(parsed)
      expect(result).to eq([:outer, [:inner, "value"]])
    end

    it 'processes empty expression end-to-end' do
      input = '()'
      parsed = parser.parse(input)
      result = transform.do(parsed)
      expect(result).to eq([])
    end
  end
end
