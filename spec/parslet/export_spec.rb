require 'spec_helper'
require_relative '../fixtures/examples/minilisp'

describe Parslet::Parser, "exporting to other lingos" do

  # I only update the files once I've verified the new syntax to work with
  # the respective tools. This is more an acceptance test than a real spec.

  describe "<- #to_citrus" do
    let(:citrus) { File.read(
      File.join(File.dirname(__FILE__), 'minilisp.citrus'))
    }
    it "should be valid citrus syntax" do
      # puts MiniLisp::Parser.new.to_citrus
      MiniLisp::Parser.new.to_citrus.should == citrus
    end
  end
  describe "<- #to_treetop" do
    let(:treetop) { File.read(
      File.join(File.dirname(__FILE__), 'minilisp.tt'))
    }
    it "should be valid treetop syntax" do
      # puts MiniLisp::Parser.new.to_treetop
      MiniLisp::Parser.new.to_treetop.should == treetop
    end
  end
end
