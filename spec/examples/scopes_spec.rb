require 'spec_helper'
require 'fixtures/examples/scopes'

RSpec.describe 'Scopes Example' do
  include ScopesExample

  describe 'ScopesExample basic scoping' do
    describe '.create_parser' do
      let(:parser) { ScopesExample.create_parser }

      it 'returns a parslet atom' do
        expect(parser).to respond_to(:parse)
      end

      it 'parses the expected scoped pattern "aba"' do
        result = parser.parse('aba')
        expect(result).to be_a(Parslet::Slice)
        expect(result.to_s).to eq('aba')
      end

      it 'demonstrates scope behavior - captures work as expected' do
        # The parser: str('a').capture(:a) >> scope { str('b').capture(:a) } >> dynamic { |s,c| str(c.captures[:a]) }
        # First captures 'a' as :a, then in scope captures 'b' as :a
        # The dynamic part uses the outer :a capture (which is 'a') to match the last character
        # So it should parse 'aba'
        result = parser.parse('aba')
        expect(result).to be_a(Parslet::Slice)
        expect(result.to_s).to eq('aba')
      end

      it 'fails when dynamic part does not match outer capture' do
        # Should fail because the last character should match the outer capture 'a', not 'b'
        expect { parser.parse('abb') }.to raise_error(Parslet::ParseFailed)
      end

      it 'fails on completely invalid input' do
        expect { parser.parse('xyz') }.to raise_error(Parslet::ParseFailed)
      end

      it 'fails on partial input' do
        expect { parser.parse('ab') }.to raise_error(Parslet::ParseFailed)
      end
    end

    describe '.parse_scoped_input' do
      it 'parses default input successfully' do
        # Default should be 'aba' based on actual scoping behavior
        result = ScopesExample.parse_scoped_input('aba')
        expect(result).to be_a(Parslet::Slice)
        expect(result.to_s).to eq('aba')
      end

      it 'parses custom valid input' do
        result = ScopesExample.parse_scoped_input('aba')
        expect(result).to be_a(Parslet::Slice)
        expect(result.to_s).to eq('aba')
      end

      it 'fails on invalid input' do
        expect { ScopesExample.parse_scoped_input('abc') }.to raise_error(Parslet::ParseFailed)
      end
    end

    describe '.demonstrate_scope_success' do
      it 'demonstrates successful scoped parsing' do
        # This should work with the correct scoped pattern
        result = ScopesExample.demonstrate_scope_success
        expect(result).to be_a(Parslet::Slice)
        expect(result.to_s).to eq('aba')
      end
    end

    describe '.demonstrate_scope_failure' do
      it 'returns ParseFailed exception instead of raising it' do
        result = ScopesExample.demonstrate_scope_failure
        expect(result).to be_a(Parslet::ParseFailed)
      end

      it 'captures the error message' do
        error = ScopesExample.demonstrate_scope_failure
        expect(error.message).to be_a(String)
        expect(error.message.length).to be > 0
      end

      it 'does not raise an exception' do
        expect { ScopesExample.demonstrate_scope_failure }.not_to raise_error
      end
    end
  end

  describe 'ScopesExample nested scoping' do
    describe '.create_nested_scope_parser' do
      let(:parser) { ScopesExample.create_nested_scope_parser }

      it 'returns a parslet atom' do
        expect(parser).to respond_to(:parse)
      end

      it 'parses nested scoped pattern correctly' do
        # Parser: str('x').capture(:outer) >> scope { str('y').capture(:outer) >> dynamic { |s,c| str(c.captures[:outer]) } } >> dynamic { |s,c| str(c.captures[:outer]) }
        # Captures 'x' as :outer, then in scope 'y' shadows :outer, first dynamic uses 'y', then outer dynamic uses original 'x'
        # So pattern should be: x y y x = 'xyyx'
        result = parser.parse('xyyx')
        expect(result).to be_a(Parslet::Slice)
        expect(result.to_s).to eq('xyyx')
      end

      it 'fails on incorrect nested pattern' do
        expect { parser.parse('xyzx') }.to raise_error(Parslet::ParseFailed)
      end

      it 'fails on partial input' do
        expect { parser.parse('xy') }.to raise_error(Parslet::ParseFailed)
      end
    end

    describe '.parse_nested_scoped_input' do
      it 'parses default nested input successfully' do
        # Default should be 'xyyx' based on nested scoping
        result = ScopesExample.parse_nested_scoped_input('xyyx')
        expect(result).to be_a(Parslet::Slice)
        expect(result.to_s).to eq('xyyx')
      end

      it 'parses custom valid nested input' do
        result = ScopesExample.parse_nested_scoped_input('xyyx')
        expect(result).to be_a(Parslet::Slice)
        expect(result.to_s).to eq('xyyx')
      end

      it 'fails on invalid nested input' do
        expect { ScopesExample.parse_nested_scoped_input('xyzx') }.to raise_error(Parslet::ParseFailed)
      end
    end
  end

  describe 'scope behavior demonstration' do
    it 'shows how scopes work with captures' do
      parser = ScopesExample.create_parser

      # The parser demonstrates scope behavior with captures
      # The dynamic part uses the outer :a capture (which is 'a')
      result = parser.parse('aba')
      expect(result.to_s).to eq('aba')
    end

    it 'shows nested scope behavior' do
      parser = ScopesExample.create_nested_scope_parser

      # Demonstrates multiple levels of scoping
      result = parser.parse('xyyx')
      expect(result.to_s).to eq('xyyx')
    end

    it 'demonstrates scope functionality' do
      # Test the basic scoped parser
      parser1 = ScopesExample.create_parser

      # Should work with the correct pattern
      expect(parser1.parse('aba').to_s).to eq('aba')
    end
  end

  describe 'error handling' do
    it 'provides meaningful error messages for scope violations' do
      parser = ScopesExample.create_parser

      begin
        parser.parse('abc')
        fail 'Expected ParseFailed to be raised'
      rescue Parslet::ParseFailed => e
        expect(e.message).to be_a(String)
        expect(e.message.length).to be > 0
      end
    end

    it 'handles empty input' do
      parser = ScopesExample.create_parser
      expect { parser.parse('') }.to raise_error(Parslet::ParseFailed)
    end

    it 'handles malformed input for nested scopes' do
      parser = ScopesExample.create_nested_scope_parser
      expect { parser.parse('invalid') }.to raise_error(Parslet::ParseFailed)
    end
  end
end
