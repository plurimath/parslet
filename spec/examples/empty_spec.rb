require 'spec_helper'
require_relative '../fixtures/examples/empty'

RSpec.describe 'Empty Parser Example' do
  let(:parser) { EmptyExample::MyParser.new }

  describe EmptyExample::MyParser do
    describe '#empty' do
      it 'raises NotImplementedError when called' do
        expect { parser.empty.parslet }.to raise_error(NotImplementedError)
      end

      it 'demonstrates empty rule behavior' do
        # The empty rule has no implementation, so accessing its parslet should fail
        expect { parser.empty.parslet }.to raise_error(NotImplementedError, /rule.*empty.*not.*implemented/i)
      end
    end
  end

  describe 'integration test' do
    it 'reproduces the behavior from the example file' do
      # The example file calls MyParser.new.empty.parslet which should raise NotImplementedError
      expect { EmptyExample::MyParser.new.empty.parslet }.to raise_error(NotImplementedError)
    end

    it 'shows that empty rules can be used for quick parser specification' do
      # This demonstrates the concept mentioned in the comment:
      # "A way to quickly spec out your parser rules?"

      # You can define the rule structure without implementation
      expect(parser).to respond_to(:empty)

      # But trying to use it will remind you to implement it
      expect { parser.empty.parslet }.to raise_error(NotImplementedError)
    end
  end
end
