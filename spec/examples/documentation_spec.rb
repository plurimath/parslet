require 'spec_helper'
require 'fixtures/examples/documentation'

RSpec.describe 'Documentation Example' do
  include DocumentationExample

  describe 'DocumentationExample::MyParser' do
    let(:parser) { DocumentationExample::MyParser.new }

    describe 'basic parsing functionality' do
      describe '#a rule' do
        it 'parses empty string (zero repetitions)' do
          result = parser.a.parse('')
          expect(result.to_s).to eq('')
        end

        it 'parses single "a"' do
          result = parser.a.parse('a')
          expect(result.to_s).to eq('a')
        end

        it 'parses multiple "a" characters' do
          result = parser.a.parse('aaaa')
          expect(result.to_s).to eq('aaaa')
        end

        it 'parses long sequence of "a" characters' do
          input = 'a' * 10
          result = parser.a.parse(input)
          expect(result.to_s).to eq(input)
        end

        it 'fails on non-"a" characters' do
          expect { parser.a.parse('b') }.to raise_error(Parslet::ParseFailed)
        end

        it 'fails on mixed characters' do
          expect { parser.a.parse('aab') }.to raise_error(Parslet::ParseFailed)
        end
      end

      describe '#parse method' do
        it 'parses valid input successfully' do
          result = parser.parse('aaaa')
          expect(result.to_s).to eq('aaaa')
        end

        it 'handles empty input' do
          result = parser.parse('')
          expect(result.to_s).to eq('')
        end

        it 'raises ParseFailed for invalid input' do
          expect { parser.parse('bbbb') }.to raise_error(Parslet::ParseFailed)
        end

        it 'raises ParseFailed for partially valid input' do
          expect { parser.parse('aaab') }.to raise_error(Parslet::ParseFailed)
        end
      end
    end

    describe 'error handling and reporting' do
      it 'provides meaningful error messages' do
        begin
          parser.parse('bbbb')
          fail 'Expected ParseFailed to be raised'
        rescue Parslet::ParseFailed => e
          expect(e.message).to include('Extra input after last repetition')
          expect(e.message).to include('line 1')
          expect(e.message).to include('char 1')
        end
      end

      it 'reports correct position for errors' do
        begin
          parser.parse('aaab')
          fail 'Expected ParseFailed to be raised'
        rescue Parslet::ParseFailed => e
          expect(e.message).to include('char 4')
        end
      end

      it 'handles different types of invalid input' do
        invalid_inputs = ['x', '123', 'aax', 'xa']

        invalid_inputs.each do |input|
          expect { parser.parse(input) }.to raise_error(Parslet::ParseFailed)
        end
      end
    end

    describe 'edge cases' do
      it 'handles very long valid input' do
        long_input = 'a' * 1000
        result = parser.parse(long_input)
        expect(result.to_s).to eq(long_input)
      end

      it 'handles single character invalid input' do
        expect { parser.parse('z') }.to raise_error(Parslet::ParseFailed)
      end

      it 'handles whitespace input' do
        expect { parser.parse(' ') }.to raise_error(Parslet::ParseFailed)
      end

      it 'handles special characters' do
        special_chars = ['!', '@', '#', '$', '%', '^', '&', '*']

        special_chars.each do |char|
          expect { parser.parse(char) }.to raise_error(Parslet::ParseFailed)
        end
      end
    end
  end

  describe 'module helper methods' do
    describe '.parse_a_sequence' do
      it 'parses valid sequences' do
        result = DocumentationExample.parse_a_sequence('aaa')
        expect(result.to_s).to eq('aaa')
      end

      it 'handles empty input' do
        result = DocumentationExample.parse_a_sequence('')
        expect(result.to_s).to eq('')
      end

      it 'raises error for invalid input' do
        expect { DocumentationExample.parse_a_sequence('bbb') }.to raise_error(Parslet::ParseFailed)
      end
    end

    describe '.demonstrate_success' do
      it 'returns successful parse result' do
        result = DocumentationExample.demonstrate_success
        expect(result.to_s).to eq('aaaa')
      end

      it 'demonstrates successful parsing without raising errors' do
        expect { DocumentationExample.demonstrate_success }.not_to raise_error
      end
    end

    describe '.demonstrate_failure' do
      it 'returns ParseFailed exception instead of raising it' do
        result = DocumentationExample.demonstrate_failure
        expect(result).to be_a(Parslet::ParseFailed)
      end

      it 'captures the error message' do
        error = DocumentationExample.demonstrate_failure
        expect(error.message).to include('Extra input after last repetition')
      end

      it 'does not raise an exception' do
        expect { DocumentationExample.demonstrate_failure }.not_to raise_error
      end
    end
  end

  describe 'documentation and demonstration purposes' do
    it 'shows basic parslet functionality' do
      # This test demonstrates the basic use case shown in documentation
      parser = DocumentationExample::MyParser.new

      # Successful case
      success_result = parser.parse('aaaa')
      expect(success_result.to_s).to eq('aaaa')

      # Failure case
      expect { parser.parse('bbbb') }.to raise_error(Parslet::ParseFailed)
    end

    it 'demonstrates error reporting capabilities' do
      # This test shows how parslet reports errors for documentation
      parser = DocumentationExample::MyParser.new

      begin
        parser.parse('invalid')
        fail 'Should have raised ParseFailed'
      rescue Parslet::ParseFailed => e
        # Error should contain useful information
        expect(e.message).to be_a(String)
        expect(e.message.length).to be > 0
        expect(e.message).to include('Extra input after last repetition')
      end
    end

    it 'shows the difference between success and failure' do
      # Demonstrates the contrast for documentation purposes
      valid_inputs = ['', 'a', 'aa', 'aaa', 'aaaa', 'aaaaa']
      invalid_inputs = ['b', 'ab', 'ba', 'aab', 'baa', 'xyz']

      valid_inputs.each do |input|
        expect { DocumentationExample.parse_a_sequence(input) }.not_to raise_error
      end

      invalid_inputs.each do |input|
        expect { DocumentationExample.parse_a_sequence(input) }.to raise_error(Parslet::ParseFailed)
      end
    end
  end
end
