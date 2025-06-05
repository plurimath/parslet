require 'spec_helper'

describe Parslet::Parser do
  include Parslet
  class FooParser < Parslet::Parser
    rule(:foo) { str('foo') }
    root(:foo)
  end

  describe '<- .root' do
    parser = Class.new(Parslet::Parser)
    parser.root :root_parslet

    it "has defined a 'root' method, returning the root" do
      parser_instance = parser.new
      expect(parser_instance).to receive(:root_parslet).and_return(:answer)

      parser_instance.root.should == :answer
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
