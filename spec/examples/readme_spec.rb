require 'spec_helper'
require 'fixtures/examples/readme'

RSpec.describe 'Readme Example' do
  include ReadmeExample

  describe 'basic parslet functionality' do
    context 'string parsing' do
      it 'parses simple strings' do
        parser = str('foo')
        result = parser.parse('foo')
        expect(result).to be_a(Parslet::Slice)
        expect(result.to_s).to eq('foo')
      end

      it 'fails on non-matching strings' do
        parser = str('foo')
        expect { parser.parse('bar') }.to raise_error(Parslet::ParseFailed)
      end
    end

    context 'character set matching' do
      let(:parser) { Parslet.match('[abc]') }

      it 'matches character a' do
        result = parser.parse('a')
        expect(result).to be_a(Parslet::Slice)
        expect(result.to_s).to eq('a')
      end

      it 'matches character b' do
        result = parser.parse('b')
        expect(result).to be_a(Parslet::Slice)
        expect(result.to_s).to eq('b')
      end

      it 'matches character c' do
        result = parser.parse('c')
        expect(result).to be_a(Parslet::Slice)
        expect(result.to_s).to eq('c')
      end

      it 'fails on non-matching characters' do
        expect { parser.parse('d') }.to raise_error(Parslet::ParseFailed)
        expect { parser.parse('x') }.to raise_error(Parslet::ParseFailed)
      end
    end

    context 'annotation' do
      it 'annotates output with symbols' do
        parser = str('foo').as(:important_bit)
        result = parser.parse('foo')
        expect(result).to eq({ important_bit: 'foo' })
      end

      it 'preserves slice information in annotations' do
        parser = str('hello').as(:greeting)
        result = parser.parse('hello')
        expect(result[:greeting]).to be_a(Parslet::Slice)
        expect(result[:greeting].to_s).to eq('hello')
      end
    end
  end

  describe 'demo methods' do
    describe '.demo_basic_parsing' do
      it 'returns hash with all basic parsing results' do
        result = ReadmeExample.demo_basic_parsing

        expect(result).to be_a(Hash)
        expect(result.keys).to contain_exactly(:foo, :a, :b, :c, :annotated)

        # Check individual results
        expect(result[:foo].to_s).to eq('foo')
        expect(result[:a].to_s).to eq('a')
        expect(result[:b].to_s).to eq('b')
        expect(result[:c].to_s).to eq('c')
        expect(result[:annotated]).to eq({ important_bit: 'foo' })
      end
    end

    describe '.demo_simple_string' do
      it 'parses quoted strings' do
        result = ReadmeExample.demo_simple_string
        expect(result).to be_a(Parslet::Slice)
        expect(result.to_s).to eq('"Simple Simple Simple"')
      end
    end

    describe '.demo_smalltalk' do
      it 'parses smalltalk keyword' do
        result = ReadmeExample.demo_smalltalk
        expect(result).to be_a(Parslet::Slice)
        expect(result.to_s).to eq('smalltalk')
      end
    end
  end

  describe ReadmeExample::SimpleStringParser do
    let(:parser) { ReadmeExample::SimpleStringParser.new }

    it 'parses simple quoted strings' do
      result = parser.parse('"hello"')
      expect(result).to be_a(Parslet::Slice)
      expect(result.to_s).to eq('"hello"')
    end

    it 'parses strings with spaces' do
      result = parser.parse('"hello world"')
      expect(result).to be_a(Parslet::Slice)
      expect(result.to_s).to eq('"hello world"')
    end

    it 'parses empty strings' do
      result = parser.parse('""')
      expect(result).to be_a(Parslet::Slice)
      expect(result.to_s).to eq('""')
    end

    it 'parses strings with special characters' do
      result = parser.parse('"hello!@#$%^&*()"')
      expect(result).to be_a(Parslet::Slice)
      expect(result.to_s).to eq('"hello!@#$%^&*()"')
    end

    it 'fails on unquoted strings' do
      expect { parser.parse('hello') }.to raise_error(Parslet::ParseFailed)
    end

    it 'fails on unclosed quotes' do
      expect { parser.parse('"hello') }.to raise_error(Parslet::ParseFailed)
    end

    it 'fails on strings starting without quote' do
      expect { parser.parse('hello"') }.to raise_error(Parslet::ParseFailed)
    end
  end

  describe ReadmeExample::SmalltalkParser do
    let(:parser) { ReadmeExample::SmalltalkParser.new }

    it 'parses smalltalk keyword' do
      result = parser.parse('smalltalk')
      expect(result).to be_a(Parslet::Slice)
      expect(result.to_s).to eq('smalltalk')
    end

    it 'fails on other keywords' do
      expect { parser.parse('ruby') }.to raise_error(Parslet::ParseFailed)
      expect { parser.parse('python') }.to raise_error(Parslet::ParseFailed)
    end

    it 'fails on partial matches' do
      expect { parser.parse('small') }.to raise_error(Parslet::ParseFailed)
      expect { parser.parse('smalltalking') }.to raise_error(Parslet::ParseFailed)
    end
  end

  describe 'integration with original readme examples' do
    it 'reproduces str parsing example' do
      result = str('foo').parse('foo')
      expect(result).to be_a(Parslet::Slice)
      expect(result.to_s).to eq('foo')
    end

    it 'reproduces match parsing examples' do
      parser = Parslet.match('[abc]')
      expect(parser.parse('a').to_s).to eq('a')
      expect(parser.parse('b').to_s).to eq('b')
      expect(parser.parse('c').to_s).to eq('c')
    end

    it 'reproduces annotation example' do
      result = str('foo').as(:important_bit).parse('foo')
      expect(result).to eq({ important_bit: 'foo' })
    end

    it 'reproduces simple string parser example' do
      quote = str('"')
      simple_string = quote >> (quote.absent? >> any).repeat >> quote
      result = simple_string.parse('"Simple Simple Simple"')
      expect(result).to be_a(Parslet::Slice)
      expect(result.to_s).to eq('"Simple Simple Simple"')
    end

    it 'reproduces smalltalk parser example' do
      parser = ReadmeExample::SmalltalkParser.new
      result = parser.parse('smalltalk')
      expect(result).to be_a(Parslet::Slice)
      expect(result.to_s).to eq('smalltalk')
    end
  end

  describe 'error handling' do
    it 'provides meaningful error messages for string parsing' do
      expect { str('foo').parse('bar') }.to raise_error(Parslet::ParseFailed, /Expected "foo"/)
    end

    it 'provides meaningful error messages for character set parsing' do
      expect { Parslet.match('[abc]').parse('x') }.to raise_error(Parslet::ParseFailed, /Failed to match \[abc\]/)
    end

    it 'handles empty input appropriately' do
      expect { str('foo').parse('') }.to raise_error(Parslet::ParseFailed)
      expect { Parslet.match('[abc]').parse('') }.to raise_error(Parslet::ParseFailed)
    end
  end

  describe 'edge cases' do
    it 'handles whitespace in string parsing' do
      parser = str(' ')
      result = parser.parse(' ')
      expect(result.to_s).to eq(' ')
    end

    it 'handles special characters in match parsing' do
      parser = Parslet.match('[\n\t]')
      expect(parser.parse("\n").to_s).to eq("\n")
      expect(parser.parse("\t").to_s).to eq("\t")
    end

    it 'handles unicode characters' do
      parser = str('café')
      result = parser.parse('café')
      expect(result.to_s).to eq('café')
    end
  end
end
