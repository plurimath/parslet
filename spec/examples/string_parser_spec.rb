require 'spec_helper'

# Load the example file to get the classes
$:.unshift File.dirname(__FILE__) + "/../../example"

# Define the classes directly to avoid eval issues
require 'pp'
require 'parslet'

include Parslet

class LiteralsParser < Parslet::Parser
  rule :space do
    (match '[ ]').repeat(1)
  end

  rule :literals do
    (literal >> eol).repeat
  end

  rule :literal do
    (integer | string).as(:literal) >> space.maybe
  end

  rule :string do
    str('"') >>
    (
      (str('\\') >> any) |
      (str('"').absent? >> any)
    ).repeat.as(:string) >>
    str('"')
  end

  rule :integer do
    match('[0-9]').repeat(1).as(:integer)
  end

  rule :eol do
    line_end.repeat(1)
  end

  rule :line_end do
    crlf >> space.maybe
  end

  rule :crlf do
    match('[\r\n]').repeat(1)
  end

  root :literals
end

class StringParserLit < Struct.new(:text)
  def to_s
    text.inspect
  end
end

class StringParserStringLit < StringParserLit
end

class StringParserIntLit < StringParserLit
  def to_s
    text
  end
end

RSpec.describe 'String Parser Example' do
  let(:parser) { LiteralsParser.new }
  let(:transform) {
    Parslet::Transform.new do
      rule(:literal => {:integer => simple(:x)}) { StringParserIntLit.new(x) }
      rule(:literal => {:string => simple(:s)}) { StringParserStringLit.new(s) }
    end
  }

  describe LiteralsParser do
    describe '#integer' do
      it 'parses single digit integers' do
        result = parser.integer.parse('5')
        expect(result).to eq({:integer => '5'})
      end

      it 'parses multi-digit integers' do
        result = parser.integer.parse('12345')
        expect(result).to eq({:integer => '12345'})
      end

      it 'fails on non-numeric input' do
        expect { parser.integer.parse('abc') }.to raise_error(Parslet::ParseFailed)
      end

      it 'fails on empty input' do
        expect { parser.integer.parse('') }.to raise_error(Parslet::ParseFailed)
      end
    end

    describe '#string' do
      it 'parses simple quoted strings' do
        result = parser.string.parse('"hello"')
        expect(result).to eq({:string => 'hello'})
      end

      it 'parses empty strings' do
        result = parser.string.parse('""')
        expect(result).to eq({:string => []})
      end

      it 'parses strings with escaped quotes' do
        result = parser.string.parse('"hello \"world\""')
        expect(result).to eq({:string => 'hello \"world\"'})
      end

      it 'parses strings with other escaped characters' do
        result = parser.string.parse('"hello\\nworld"')
        expect(result).to eq({:string => 'hello\\nworld'})
      end

      it 'fails on unquoted strings' do
        expect { parser.string.parse('hello') }.to raise_error(Parslet::ParseFailed)
      end

      it 'fails on unclosed strings' do
        expect { parser.string.parse('"hello') }.to raise_error(Parslet::ParseFailed)
      end
    end

    describe '#literal' do
      it 'parses integer literals' do
        result = parser.literal.parse('123')
        expect(result).to eq({:literal => {:integer => '123'}})
      end

      it 'parses string literals' do
        result = parser.literal.parse('"hello"')
        expect(result).to eq({:literal => {:string => 'hello'}})
      end

      it 'parses literals with trailing spaces' do
        result = parser.literal.parse('123 ')
        expect(result).to eq({:literal => {:integer => '123'}})
      end
    end

    describe '#space' do
      it 'parses single space' do
        result = parser.space.parse(' ')
        expect(result.to_s).to eq(' ')
      end

      it 'parses multiple spaces' do
        result = parser.space.parse('   ')
        expect(result.to_s).to eq('   ')
      end

      it 'fails on empty input' do
        expect { parser.space.parse('') }.to raise_error(Parslet::ParseFailed)
      end

      it 'fails on non-space characters' do
        expect { parser.space.parse('a') }.to raise_error(Parslet::ParseFailed)
      end
    end

    describe '#crlf' do
      it 'parses carriage return' do
        result = parser.crlf.parse("\r")
        expect(result.to_s).to eq("\r")
      end

      it 'parses line feed' do
        result = parser.crlf.parse("\n")
        expect(result.to_s).to eq("\n")
      end

      it 'parses CRLF sequence' do
        result = parser.crlf.parse("\r\n")
        expect(result.to_s).to eq("\r\n")
      end

      it 'parses multiple newlines' do
        result = parser.crlf.parse("\n\n")
        expect(result.to_s).to eq("\n\n")
      end
    end

    describe '#line_end' do
      it 'parses newline without space' do
        result = parser.line_end.parse("\n")
        expect(result.to_s).to eq("\n")
      end

      it 'parses newline with trailing space' do
        result = parser.line_end.parse("\n ")
        expect(result.to_s).to eq("\n ")
      end
    end

    describe '#eol' do
      it 'parses single end of line' do
        result = parser.eol.parse("\n")
        expect(result.to_s).to eq("\n")
      end

      it 'parses multiple end of lines' do
        result = parser.eol.parse("\n\n")
        expect(result.to_s).to eq("\n\n")
      end
    end

    describe '#literals (root)' do
      it 'parses single integer literal' do
        result = parser.parse("123\n")
        expect(result).to eq([{:literal => {:integer => '123'}}])
      end

      it 'parses single string literal' do
        result = parser.parse("\"hello\"\n")
        expect(result).to eq([{:literal => {:string => 'hello'}}])
      end

      it 'parses multiple literals' do
        input = "123\n\"hello\"\n456\n"
        result = parser.parse(input)
        expect(result).to eq([
          {:literal => {:integer => '123'}},
          {:literal => {:string => 'hello'}},
          {:literal => {:integer => '456'}}
        ])
      end

      it 'parses literals with spaces' do
        input = "123 \n\"hello\" \n"
        result = parser.parse(input)
        expect(result).to eq([
          {:literal => {:integer => '123'}},
          {:literal => {:string => 'hello'}}
        ])
      end

      it 'handles empty input' do
        result = parser.parse("")
        expect(result).to eq("")
      end
    end
  end

  describe 'Transform classes' do
    describe StringParserLit do
      it 'stores text and converts to inspect format' do
        lit = StringParserLit.new('hello')
        expect(lit.text).to eq('hello')
        expect(lit.to_s).to eq('"hello"')
      end
    end

    describe StringParserStringLit do
      it 'inherits from StringParserLit' do
        string_lit = StringParserStringLit.new('hello')
        expect(string_lit).to be_a(StringParserLit)
        expect(string_lit.text).to eq('hello')
        expect(string_lit.to_s).to eq('"hello"')
      end
    end

    describe StringParserIntLit do
      it 'inherits from StringParserLit but shows text directly' do
        int_lit = StringParserIntLit.new('123')
        expect(int_lit).to be_a(StringParserLit)
        expect(int_lit.text).to eq('123')
        expect(int_lit.to_s).to eq('123')
      end
    end
  end

  describe 'Transform rules' do
    it 'transforms integer literals to StringParserIntLit objects' do
      parse_result = {:literal => {:integer => '123'}}
      result = transform.apply(parse_result)
      expect(result).to be_a(StringParserIntLit)
      expect(result.text).to eq('123')
      expect(result.to_s).to eq('123')
    end

    it 'transforms string literals to StringParserStringLit objects' do
      parse_result = {:literal => {:string => 'hello'}}
      result = transform.apply(parse_result)
      expect(result).to be_a(StringParserStringLit)
      expect(result.text).to eq('hello')
      expect(result.to_s).to eq('"hello"')
    end

    it 'transforms arrays of literals' do
      parse_result = [
        {:literal => {:integer => '123'}},
        {:literal => {:string => 'hello'}}
      ]
      result = transform.apply(parse_result)
      expect(result).to be_an(Array)
      expect(result.length).to eq(2)
      expect(result[0]).to be_a(StringParserIntLit)
      expect(result[1]).to be_a(StringParserStringLit)
    end
  end

  describe 'integration test with simple.lit file' do
    let(:simple_lit_content) { "123\n12345\n\" Some String with \\\"escapes\\\"\"\n" }

    it 'parses the simple.lit file correctly' do
      result = parser.parse(simple_lit_content)
      expect(result).to eq([
        {:literal => {:integer => '123'}},
        {:literal => {:integer => '12345'}},
        {:literal => {:string => ' Some String with \"escapes\"'}}
      ])
    end

    it 'transforms the simple.lit file to AST objects' do
      parse_result = parser.parse(simple_lit_content)
      ast = transform.apply(parse_result)

      expect(ast).to be_an(Array)
      expect(ast.length).to eq(3)

      # First integer
      expect(ast[0]).to be_a(StringParserIntLit)
      expect(ast[0].text).to eq('123')
      expect(ast[0].to_s).to eq('123')

      # Second integer
      expect(ast[1]).to be_a(StringParserIntLit)
      expect(ast[1].text).to eq('12345')
      expect(ast[1].to_s).to eq('12345')

      # String with escapes
      expect(ast[2]).to be_a(StringParserStringLit)
      expect(ast[2].text.to_s).to include('Some String with')
      expect(ast[2].text.to_s).to include('escapes')
      expect(ast[2].to_s).to include('Some String with')
      expect(ast[2].to_s).to include('escapes')
    end

    it 'reproduces the example behavior' do
      # This test reproduces what the example file does:
      # 1. Parse the simple.lit file
      # 2. Transform to AST objects
      # 3. Verify the structure

      parsetree = LiteralsParser.new.parse(simple_lit_content)

      transform = Parslet::Transform.new do
        rule(:literal => {:integer => simple(:x)}) { StringParserIntLit.new(x) }
        rule(:literal => {:string => simple(:s)}) { StringParserStringLit.new(s) }
      end

      ast = transform.apply(parsetree)

      # Verify we have the expected structure
      expect(ast).to be_an(Array)
      expect(ast.length).to eq(3)
      expect(ast.all? { |item| item.is_a?(StringParserLit) }).to be true

      # Verify the types and values
      expect(ast[0]).to be_a(StringParserIntLit)
      expect(ast[1]).to be_a(StringParserIntLit)
      expect(ast[2]).to be_a(StringParserStringLit)
    end
  end

  describe 'edge cases and error handling' do
    it 'handles mixed content correctly' do
      input = "42\n\"test\"\n999\n\"another\"\n"
      result = parser.parse(input)
      expect(result.length).to eq(4)
      expect(result[0][:literal][:integer]).to eq('42')
      expect(result[1][:literal][:string]).to eq('test')
      expect(result[2][:literal][:integer]).to eq('999')
      expect(result[3][:literal][:string]).to eq('another')
    end

    it 'handles strings with various escape sequences' do
      input = "\"line1\\nline2\"\n\"quote: \\\"hello\\\"\"\n"
      result = parser.parse(input)
      expect(result.length).to eq(2)
      expect(result[0][:literal][:string]).to eq('line1\\nline2')
      expect(result[1][:literal][:string].to_s).to match(/quote: \\"hello\\"/)
    end

    it 'fails on malformed input' do
      expect { parser.parse('123 "unclosed string') }.to raise_error(Parslet::ParseFailed)
      expect { parser.parse('not_a_literal\n') }.to raise_error(Parslet::ParseFailed)
    end

    it 'handles large integers' do
      input = "999999999999999999\n"
      result = parser.parse(input)
      expect(result[0][:literal][:integer]).to eq('999999999999999999')
    end

    it 'handles empty strings in mixed content' do
      input = "123\n\"\"\n456\n"
      result = parser.parse(input)
      expect(result.length).to eq(3)
      expect(result[1][:literal][:string]).to eq([])
    end
  end
end
