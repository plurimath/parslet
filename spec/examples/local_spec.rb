require 'spec_helper'
require 'fixtures/examples/local'

RSpec.describe 'Local Example' do
  include Parslet

  describe 'LocalExample module methods' do
    describe '.this' do
      it 'creates a Parslet::Atoms::Entity' do
        entity = LocalExample.this('test') { str('a') }
        expect(entity).to be_a(Parslet::Atoms::Entity)
      end

      it 'accepts a block for recursive definitions' do
        expect { LocalExample.this('test') { str('a') } }.not_to raise_error
      end
    end

    describe '.epsilon' do
      it 'creates an epsilon parser (matches empty string)' do
        epsilon = LocalExample.epsilon
        expect(epsilon).to be_a(Parslet::Atoms::Base)
      end

      it 'matches empty input' do
        result = LocalExample.epsilon.parse('')
        expect(result.to_s).to eq('')
      end

      it 'fails on non-empty input' do
        expect { LocalExample.epsilon.parse('a') }.to raise_error(Parslet::ParseFailed)
      end
    end

    describe '.simple_inline_parser' do
      it 'parses minimum valid input ("aa")' do
        result = LocalExample.simple_inline_parser.parse('aa')
        expect(result.to_s).to eq('aa')
      end

      it 'parses sequences with additional "a"s before "aa"' do
        result = LocalExample.simple_inline_parser.parse('aaa')
        expect(result.to_s).to eq('aaa')
      end

      it 'parses longer sequences' do
        result = LocalExample.simple_inline_parser.parse('aaaaa')
        expect(result.to_s).to eq('aaaaa')
      end

      it 'parses longest supported sequence' do
        result = LocalExample.simple_inline_parser.parse('aaaaaa')
        expect(result.to_s).to eq('aaaaaa')
      end

      it 'fails on sequences longer than supported' do
        expect { LocalExample.simple_inline_parser.parse('aaaaaaa') }.to raise_error(Parslet::ParseFailed)
      end

      it 'fails on single "a"' do
        expect { LocalExample.simple_inline_parser.parse('a') }.to raise_error(Parslet::ParseFailed)
      end

      it 'fails on empty input' do
        expect { LocalExample.simple_inline_parser.parse('') }.to raise_error(Parslet::ParseFailed)
      end

      it 'fails on non-"a" characters' do
        expect { LocalExample.simple_inline_parser.parse('baa') }.to raise_error(Parslet::ParseFailed)
      end
    end

    describe '.greedy_blind_parser' do
      it 'parses sequences of "a" greedily' do
        result = LocalExample.greedy_blind_parser.parse('aaaa')
        expect(result).to be_a(Hash)
        expect(result).to have_key(:e)
      end

      it 'handles empty input (epsilon case)' do
        result = LocalExample.greedy_blind_parser.parse('')
        expect(result.to_s).to eq('')
      end

      it 'handles single "a"' do
        result = LocalExample.greedy_blind_parser.parse('a')
        expect(result).to be_a(Hash)
        expect(result[:e].to_s).to eq('a')
      end

      it 'creates recursive structure for multiple "a"s' do
        result = LocalExample.greedy_blind_parser.parse('aaa')
        expect(result).to be_a(Hash)
        expect(result).to have_key(:e)
        expect(result).to have_key(:rec)
      end

      it 'fails on non-"a" characters' do
        expect { LocalExample.greedy_blind_parser.parse('b') }.to raise_error(Parslet::ParseFailed)
      end
    end

    describe '.greedy_non_blind_parser' do
      it 'parses "aa" as end pattern' do
        result = LocalExample.greedy_non_blind_parser.parse('aa')
        expect(result).to be_a(Hash)
        expect(result).to have_key(:e2)
        expect(result[:e2].to_s).to eq('aa')
      end

      it 'handles longer sequences ending with "aa"' do
        result = LocalExample.greedy_non_blind_parser.parse('aaaa')
        expect(result).to be_a(Hash)
        # Should have both e1 and rec components
        expect(result).to have_key(:e1)
        expect(result).to have_key(:rec)
      end

      it 'creates recursive structure for complex patterns' do
        result = LocalExample.greedy_non_blind_parser.parse('aaaaaa')
        expect(result).to be_a(Hash)
        expect(result).to have_key(:e1)
        expect(result).to have_key(:rec)
      end

      it 'fails on single "a"' do
        expect { LocalExample.greedy_non_blind_parser.parse('a') }.to raise_error(Parslet::ParseFailed)
      end

      it 'fails on empty input' do
        expect { LocalExample.greedy_non_blind_parser.parse('') }.to raise_error(Parslet::ParseFailed)
      end
    end

    describe '.demonstrate_local_variables' do
      it 'returns a parser constructed with local variables' do
        parser = LocalExample.demonstrate_local_variables
        expect(parser).to be_a(Parslet::Atoms::Base)
      end

      it 'creates a working parser from local variables' do
        parser = LocalExample.demonstrate_local_variables
        result = parser.parse('aaaa')
        expect(result.to_s).to eq('aaaa')
      end

      it 'demonstrates local variable scoping' do
        parser = LocalExample.demonstrate_local_variables
        expect { parser.parse('aa') }.not_to raise_error
      end
    end
  end

  describe 'parsing methods' do
    describe '.parse_with_greedy_blind' do
      it 'parses input using greedy blind parser' do
        result = LocalExample.parse_with_greedy_blind('aaa')
        expect(result).to be_a(Hash)
        expect(result).to have_key(:e)
      end

      it 'handles empty input' do
        result = LocalExample.parse_with_greedy_blind('')
        expect(result.to_s).to eq('')
      end

      it 'raises error for invalid input' do
        expect { LocalExample.parse_with_greedy_blind('b') }.to raise_error(Parslet::ParseFailed)
      end
    end

    describe '.parse_with_greedy_non_blind' do
      it 'parses input using greedy non-blind parser' do
        result = LocalExample.parse_with_greedy_non_blind('aaaa')
        expect(result).to be_a(Hash)
      end

      it 'handles minimum valid input' do
        result = LocalExample.parse_with_greedy_non_blind('aa')
        expect(result).to be_a(Hash)
        expect(result[:e2].to_s).to eq('aa')
      end

      it 'raises error for insufficient input' do
        expect { LocalExample.parse_with_greedy_non_blind('a') }.to raise_error(Parslet::ParseFailed)
      end
    end

    describe '.parse_with_simple_inline' do
      it 'parses input using simple inline parser (minimum: "aa")' do
        result = LocalExample.parse_with_simple_inline('aa')
        expect(result.to_s).to eq('aa')
      end

      it 'parses longer sequences' do
        result = LocalExample.parse_with_simple_inline('aaaaa')
        expect(result.to_s).to eq('aaaaa')
      end

      it 'raises error for single "a"' do
        expect { LocalExample.parse_with_simple_inline('a') }.to raise_error(Parslet::ParseFailed)
      end

      it 'raises error for empty input' do
        expect { LocalExample.parse_with_simple_inline('') }.to raise_error(Parslet::ParseFailed)
      end
    end
  end

  describe 'advanced parsing concepts' do
    describe 'inline parser construction' do
      it 'demonstrates parser construction without class wrapper' do
        # This shows the concept of building parsers inline
        inline_parser = str('hello') >> str(' ') >> str('world')
        result = inline_parser.parse('hello world')
        expect(result.to_s).to eq('hello world')
      end

      it 'shows local variable usage in parser building' do
        # Demonstrates using local variables to build parsers
        greeting = str('hello')
        space = str(' ')
        target = str('world')
        parser = greeting >> space >> target

        result = parser.parse('hello world')
        expect(result.to_s).to eq('hello world')
      end
    end

    describe 'greedy vs non-greedy parsing' do
      it 'compares greedy blind vs greedy non-blind behavior' do
        input = 'aaaa'

        # Both should parse successfully but with different structures
        blind_result = LocalExample.parse_with_greedy_blind(input)
        non_blind_result = LocalExample.parse_with_greedy_non_blind(input)

        expect(blind_result).to be_a(Hash)
        expect(non_blind_result).to be_a(Hash)

        # They should have different structures
        expect(blind_result.keys).not_to eq(non_blind_result.keys)
      end

      it 'shows different parsing strategies for same input' do
        input = 'aaaaaa'

        # Test that both parsers handle the input but differently
        expect { LocalExample.parse_with_greedy_blind(input) }.not_to raise_error
        expect { LocalExample.parse_with_greedy_non_blind(input) }.not_to raise_error

        blind_result = LocalExample.parse_with_greedy_blind(input)
        non_blind_result = LocalExample.parse_with_greedy_non_blind(input)

        # Results should be different in structure
        expect(blind_result).not_to eq(non_blind_result)
      end
    end

    describe 'recursive parser construction' do
      it 'demonstrates recursive entity usage' do
        # The greedy parsers use recursive entities
        result = LocalExample.parse_with_greedy_blind('aaaaa')

        # Should create nested recursive structure
        expect(result).to have_key(:e)
        expect(result).to have_key(:rec)

        # Recursive structure should be present
        current = result
        depth = 0
        while current.is_a?(Hash) && current.key?(:rec) && current[:rec].is_a?(Hash)
          current = current[:rec]
          depth += 1
          break if depth > 10 # Safety check
        end

        expect(depth).to be > 0
      end
    end

    describe 'epsilon parser behavior' do
      it 'demonstrates epsilon as empty match' do
        epsilon = LocalExample.epsilon

        # Should match empty string
        expect { epsilon.parse('') }.not_to raise_error

        # Should fail on any content
        expect { epsilon.parse('a') }.to raise_error(Parslet::ParseFailed)
        expect { epsilon.parse(' ') }.to raise_error(Parslet::ParseFailed)
      end

      it 'shows epsilon usage in alternatives' do
        # Epsilon is used in the greedy blind parser as an alternative
        result = LocalExample.parse_with_greedy_blind('')
        expect(result.to_s).to eq('')
      end
    end
  end
end
