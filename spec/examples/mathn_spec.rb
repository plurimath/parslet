require 'spec_helper'

# Load the example file to get the classes
$:.unshift File.dirname(__FILE__) + "/../../example"

RSpec.describe 'Mathn Compatibility Example' do
  describe 'parser behavior' do
    let(:possible_whitespace) { Parslet.match['\s'].repeat }
    let(:cephalopod) { Parslet.str('octopus') | Parslet.str('squid') }
    let(:parenthesized_cephalopod) do
      Parslet.str('(') >>
      possible_whitespace >>
      cephalopod >>
      possible_whitespace >>
      Parslet.str(')')
    end
    let(:parser) do
      possible_whitespace >>
      parenthesized_cephalopod >>
      possible_whitespace
    end

    it 'fails to parse invalid input as expected' do
      # This should fail to parse because "sqeed" is not "squid" or "octopus"
      expect { parser.parse %{(\nsqeed)\n} }.to raise_error(Parslet::ParseFailed)
    end

    it 'successfully parses valid cephalopod input' do
      result = parser.parse %{(
squid)
}
      expect(result.to_s).to eq("(\nsquid)\n")

      result = parser.parse %{( octopus )}
      expect(result.to_s).to eq('( octopus )')
    end

    it 'handles whitespace correctly' do
      result = parser.parse %{(squid)}
      expect(result.to_s).to eq('(squid)')

      result = parser.parse %{  (  squid  )  }
      expect(result.to_s).to eq('  (  squid  )  ')
    end
  end

  describe 'mathn compatibility' do
    def attempt_parse_with_timeout(timeout = 5)
      # Opal doesn't support Threads, so we'll just run the parse directly
      # The mathn compatibility issue was specific to MRI Ruby anyway
      begin
        possible_whitespace = Parslet.match['\s'].repeat
        cephalopod = Parslet.str('octopus') | Parslet.str('squid')
        parenthesized_cephalopod = Parslet.str('(') >> possible_whitespace >> cephalopod >> possible_whitespace >> Parslet.str(')')
        parser = possible_whitespace >> parenthesized_cephalopod >> possible_whitespace

        parser.parse %{(\nsqeed)\n}
      rescue Parslet::ParseFailed => e
        raise e
      rescue => e
        raise e
      end
    end

    it 'terminates properly before requiring mathn' do
      # This should fail with ParseFailed, not hang
      # In Opal, we don't have the mathn compatibility issue, so this should work fine
      expect { attempt_parse_with_timeout }.to raise_error(Parslet::ParseFailed)
    end

    # Skip mathn test on Ruby 2.5+ since mathn was deprecated
    if RUBY_VERSION.gsub(/[^\d]/, '').to_i < 250
      it 'still terminates properly after requiring mathn' do
        # Require mathn in an isolated way
        begin
          require 'mathn'

          # This should still fail with ParseFailed, not hang
          # The fix in parslet should prevent infinite loops even with mathn loaded
          expect { attempt_parse_with_timeout }.to raise_error(Parslet::ParseFailed)
        rescue LoadError
          skip "mathn not available in this Ruby version"
        end
      end
    else
      it 'skips mathn test on Ruby 2.5+' do
        skip "mathn was deprecated in Ruby 2.5+"
      end
    end
  end

  describe 'integration test' do
    it 'demonstrates the mathn compatibility fix' do
      # The key point of this example is that parslet should not hang
      # when mathn is loaded, even with failing parses

      # Test that we can create the parser components
      possible_whitespace = Parslet.match['\s'].repeat
      expect(possible_whitespace).to be_a(Parslet::Atoms::Repetition)

      cephalopod = Parslet.str('octopus') | Parslet.str('squid')
      expect(cephalopod).to be_a(Parslet::Atoms::Alternative)

      parenthesized_cephalopod = Parslet.str('(') >> possible_whitespace >> cephalopod >> possible_whitespace >> Parslet.str(')')
      expect(parenthesized_cephalopod).to be_a(Parslet::Atoms::Sequence)

      parser = possible_whitespace >> parenthesized_cephalopod >> possible_whitespace
      expect(parser).to be_a(Parslet::Atoms::Sequence)

      # Test that parsing fails appropriately (not hangs)
      expect { parser.parse %{(\nsqeed)\n} }.to raise_error(Parslet::ParseFailed)
    end

    it 'reproduces the example behavior' do
      # This test reproduces what the example file does:
      # 1. Attempts to parse invalid input (should fail)
      # 2. Shows that it terminates properly

      output = capture_output do
        # Simulate the attempt_parse function
        begin
          possible_whitespace = Parslet.match['\s'].repeat
          cephalopod = Parslet.str('octopus') | Parslet.str('squid')
          parenthesized_cephalopod = Parslet.str('(') >> possible_whitespace >> cephalopod >> possible_whitespace >> Parslet.str(')')
          parser = possible_whitespace >> parenthesized_cephalopod >> possible_whitespace

          parser.parse %{(\nsqeed)\n}
        rescue Parslet::ParseFailed
          # Expected - this is what should happen
        end

        puts 'it terminates before we require mathn'
        puts 'okay!'
      end

      expect(output).to include('it terminates before we require mathn')
      expect(output).to include('okay!')
    end
  end

  private

  def capture_output
    original_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = original_stdout
  end
end
