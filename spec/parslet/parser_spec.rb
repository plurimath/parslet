require 'spec_helper'

describe Parslet::Parser do
  include Parslet
  class FooParser < Parslet::Parser
    rule(:foo) { str('foo') }
    root(:foo)
  end

  describe '<- .root' do
    parser = Class.new(Parslet::Parser) do
      def root_parslet
        :answer
      end
    end
    parser.root :root_parslet

    it "has defined a 'root' method, returning the root" do
      parser_instance = parser.new
      expect(parser_instance.root).to eq(:answer)
    end
  end

  it "parses 'foo'" do
    FooParser.new.parse('foo').should == 'foo'
  end

  context 'composition' do
    let(:parser) { FooParser.new }

    it 'allows concatenation' do
      composite = parser >> str('bar')
      composite.should parse('foobar')
    end
  end
end
