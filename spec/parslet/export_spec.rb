require 'spec_helper'
require_relative '../fixtures/examples/minilisp'

RSpec.describe Parslet::Parser, "exporting to other lingos" do
  let(:parser) { MiniLisp::Parser.new }

  # I only update the files once I've verified the new syntax to work with
  # the respective tools. This is more an acceptance test than a real spec.

  describe "<- #to_citrus" do
    let(:citrus) { File.read(
      File.join(File.dirname(__FILE__), 'minilisp.citrus'))
    }

    it "should be valid citrus syntax" do

      if RUBY_ENGINE == 'opal'
        skip "Citrus export not supported in Opal, somehow?"
      end
      # puts parser.to_citrus
      parser.to_citrus.should == citrus
    end
  end

  describe "<- #to_treetop" do
    let(:treetop) { File.read(
      File.join(File.dirname(__FILE__), 'minilisp.tt'))
    }

    it "should be valid treetop syntax" do

      if RUBY_ENGINE == 'opal'
        skip "Treetop export not supported in Opal, somehow?"
      end

      # puts parser.to_treetop
      parser.to_treetop.should == treetop
    end
  end
end
