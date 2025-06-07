require 'spec_helper'
require 'fixtures/examples/modularity'

RSpec.describe 'Modularity Example' do
  include ModularityExample

  describe 'ModularityExample::ALanguage module' do
    let(:test_class) do
      Class.new do
        include ModularityExample::ALanguage
      end.new
    end

    describe '#a_language rule' do
      it 'parses "aaa" correctly' do
        result = test_class.a_language.parse('aaa')
        expect(result).to be_a(Parslet::Slice)
        expect(result.to_s).to eq('aaa')
      end

      it 'fails on incorrect input' do
        expect { test_class.a_language.parse('bbb') }.to raise_error(Parslet::ParseFailed)
      end

      it 'fails on partial match' do
        expect { test_class.a_language.parse('aa') }.to raise_error(Parslet::ParseFailed)
      end

      it 'fails on longer input' do
        expect { test_class.a_language.parse('aaaa') }.to raise_error(Parslet::ParseFailed)
      end
    end
  end

  describe 'ModularityExample::BLanguage parser' do
    let(:parser) { ModularityExample::BLanguage.new }

    describe '#blang rule' do
      it 'parses "bbb" correctly' do
        result = parser.blang.parse('bbb')
        expect(result).to be_a(Parslet::Slice)
        expect(result.to_s).to eq('bbb')
      end

      it 'fails on incorrect input' do
        expect { parser.blang.parse('aaa') }.to raise_error(Parslet::ParseFailed)
      end

      it 'fails on partial match' do
        expect { parser.blang.parse('bb') }.to raise_error(Parslet::ParseFailed)
      end

      it 'fails on longer input' do
        expect { parser.blang.parse('bbbb') }.to raise_error(Parslet::ParseFailed)
      end
    end

    describe '#parse method (root)' do
      it 'parses "bbb" correctly' do
        result = parser.parse('bbb')
        expect(result).to be_a(Parslet::Slice)
        expect(result.to_s).to eq('bbb')
      end

      it 'fails on incorrect input' do
        expect { parser.parse('ccc') }.to raise_error(Parslet::ParseFailed)
      end
    end
  end

  describe 'ModularityExample.c_language' do
    let(:c_lang) { ModularityExample.c_language }

    it 'returns a parslet atom' do
      expect(c_lang).to respond_to(:parse)
    end

    it 'parses "ccc" correctly' do
      result = c_lang.parse('ccc')
      expect(result).to be_a(Parslet::Slice)
      expect(result.to_s).to eq('ccc')
    end

    it 'fails on incorrect input' do
      expect { c_lang.parse('aaa') }.to raise_error(Parslet::ParseFailed)
    end

    it 'fails on partial match' do
      expect { c_lang.parse('cc') }.to raise_error(Parslet::ParseFailed)
    end

    it 'fails on longer input' do
      expect { c_lang.parse('cccc') }.to raise_error(Parslet::ParseFailed)
    end
  end

  describe 'ModularityExample::Language parser' do
    let(:parser) { ModularityExample::Language.new(ModularityExample.c_language) }

    describe 'initialization' do
      it 'accepts a c_language parameter' do
        expect { ModularityExample::Language.new(ModularityExample.c_language) }.not_to raise_error
      end

      it 'includes ALanguage module' do
        expect(parser).to respond_to(:a_language)
      end
    end

    describe '#root rule' do
      it 'parses a-language syntax "a(aaa)"' do
        result = parser.root.parse('a(aaa)')
        expect(result).to be_a(Parslet::Slice)
        expect(result.to_s).to eq('a(aaa)')
      end

      it 'parses a-language syntax with space "a(aaa) "' do
        result = parser.root.parse('a(aaa) ')
        expect(result).to be_a(Parslet::Slice)
        expect(result.to_s).to eq('a(aaa) ')
      end

      it 'parses b-language syntax "b(bbb)"' do
        result = parser.root.parse('b(bbb)')
        expect(result).to be_a(Parslet::Slice)
        expect(result.to_s).to eq('b(bbb)')
      end

      it 'parses b-language syntax with space "b(bbb) "' do
        result = parser.root.parse('b(bbb) ')
        expect(result).to be_a(Parslet::Slice)
        expect(result.to_s).to eq('b(bbb) ')
      end

      it 'parses c-language syntax "c(ccc)"' do
        result = parser.root.parse('c(ccc)')
        expect(result).to be_a(Parslet::Slice)
        expect(result.to_s).to eq('c(ccc)')
      end

      it 'parses c-language syntax with space "c(ccc) "' do
        result = parser.root.parse('c(ccc) ')
        expect(result).to be_a(Parslet::Slice)
        expect(result.to_s).to eq('c(ccc) ')
      end

      it 'fails on malformed a-language syntax' do
        expect { parser.root.parse('a(bbb)') }.to raise_error(Parslet::ParseFailed)
      end

      it 'fails on malformed b-language syntax' do
        expect { parser.root.parse('b(aaa)') }.to raise_error(Parslet::ParseFailed)
      end

      it 'fails on malformed c-language syntax' do
        expect { parser.root.parse('c(aaa)') }.to raise_error(Parslet::ParseFailed)
      end

      it 'fails on unknown language prefix' do
        expect { parser.root.parse('d(ddd)') }.to raise_error(Parslet::ParseFailed)
      end
    end

    describe '#parse method (root)' do
      it 'parses a-language correctly' do
        result = parser.parse('a(aaa)')
        expect(result).to be_a(Parslet::Slice)
        expect(result.to_s).to eq('a(aaa)')
      end

      it 'parses b-language correctly' do
        result = parser.parse('b(bbb)')
        expect(result).to be_a(Parslet::Slice)
        expect(result.to_s).to eq('b(bbb)')
      end

      it 'parses c-language correctly' do
        result = parser.parse('c(ccc)')
        expect(result).to be_a(Parslet::Slice)
        expect(result.to_s).to eq('c(ccc)')
      end
    end

    describe '#space rule' do
      it 'parses single space' do
        result = parser.space.parse(' ')
        expect(result).to be_a(Parslet::Slice)
        expect(result.to_s).to eq(' ')
      end

      it 'parses empty string (maybe)' do
        result = parser.space.parse('')
        expect(result.to_s).to eq('')
      end

      it 'fails on multiple spaces' do
        expect { parser.space.parse('  ') }.to raise_error(Parslet::ParseFailed)
      end
    end
  end

  describe 'module helper methods' do
    describe '.parse_a_language' do
      it 'parses default a-language input' do
        result = ModularityExample.parse_a_language
        expect(result).to be_a(Parslet::Slice)
        expect(result.to_s).to eq('a(aaa)')
      end

      it 'parses custom a-language input' do
        result = ModularityExample.parse_a_language('a(aaa) ')
        expect(result).to be_a(Parslet::Slice)
        expect(result.to_s).to eq('a(aaa) ')
      end

      it 'fails on invalid input' do
        expect { ModularityExample.parse_a_language('invalid') }.to raise_error(Parslet::ParseFailed)
      end
    end

    describe '.parse_b_language' do
      it 'parses default b-language input' do
        result = ModularityExample.parse_b_language
        expect(result).to be_a(Parslet::Slice)
        expect(result.to_s).to eq('b(bbb)')
      end

      it 'parses custom b-language input' do
        result = ModularityExample.parse_b_language('b(bbb) ')
        expect(result).to be_a(Parslet::Slice)
        expect(result.to_s).to eq('b(bbb) ')
      end

      it 'fails on invalid input' do
        expect { ModularityExample.parse_b_language('invalid') }.to raise_error(Parslet::ParseFailed)
      end
    end

    describe '.parse_c_language' do
      it 'parses default c-language input' do
        result = ModularityExample.parse_c_language
        expect(result).to be_a(Parslet::Slice)
        expect(result.to_s).to eq('c(ccc)')
      end

      it 'parses custom c-language input' do
        result = ModularityExample.parse_c_language('c(ccc) ')
        expect(result).to be_a(Parslet::Slice)
        expect(result.to_s).to eq('c(ccc) ')
      end

      it 'fails on invalid input' do
        expect { ModularityExample.parse_c_language('invalid') }.to raise_error(Parslet::ParseFailed)
      end
    end

    describe '.create_parser' do
      it 'returns a Language parser instance' do
        parser = ModularityExample.create_parser
        expect(parser).to be_a(ModularityExample::Language)
      end

      it 'creates a functional parser' do
        parser = ModularityExample.create_parser
        result = parser.parse('a(aaa)')
        expect(result.to_s).to eq('a(aaa)')
      end
    end

    describe '.c_language' do
      it 'returns a parslet atom' do
        c_lang = ModularityExample.c_language
        expect(c_lang).to respond_to(:parse)
      end

      it 'can be used to create parsers' do
        parser = ModularityExample::Language.new(ModularityExample.c_language)
        result = parser.parse('c(ccc)')
        expect(result.to_s).to eq('c(ccc)')
      end
    end
  end

  describe 'modular design demonstration' do
    it 'shows how to mix parslet rules into classes' do
      # ALanguage module demonstrates mixing rules into classes
      test_class = Class.new { include ModularityExample::ALanguage }.new
      expect(test_class).to respond_to(:a_language)
      expect(test_class.a_language.parse('aaa').to_s).to eq('aaa')
    end

    it 'shows how to use parsers as atoms' do
      # BLanguage parser used as an atom in Language parser
      parser = ModularityExample.create_parser
      result = parser.parse('b(bbb)')
      expect(result.to_s).to eq('b(bbb)')
    end

    it 'shows how to pass parslet atoms around' do
      # c_language atom passed to Language constructor
      c_atom = ModularityExample.c_language
      parser = ModularityExample::Language.new(c_atom)
      result = parser.parse('c(ccc)')
      expect(result.to_s).to eq('c(ccc)')
    end

    it 'demonstrates all three modular approaches working together' do
      parser = ModularityExample.create_parser

      # All three approaches should work in the same parser
      expect(parser.parse('a(aaa)').to_s).to eq('a(aaa)')
      expect(parser.parse('b(bbb)').to_s).to eq('b(bbb)')
      expect(parser.parse('c(ccc)').to_s).to eq('c(ccc)')
    end
  end

  describe 'error handling' do
    let(:parser) { ModularityExample.create_parser }

    it 'provides meaningful error messages for malformed input' do
      begin
        parser.parse('invalid')
        fail 'Expected ParseFailed to be raised'
      rescue Parslet::ParseFailed => e
        expect(e.message).to include('Expected one of')
        expect(e.message).to include('at line 1 char 1')
      end
    end

    it 'handles empty input' do
      expect { parser.parse('') }.to raise_error(Parslet::ParseFailed)
    end

    it 'handles partial matches' do
      expect { parser.parse('a(aa)') }.to raise_error(Parslet::ParseFailed)
      expect { parser.parse('b(bb)') }.to raise_error(Parslet::ParseFailed)
      expect { parser.parse('c(cc)') }.to raise_error(Parslet::ParseFailed)
    end
  end
end
