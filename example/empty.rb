# Basically just demonstrates that you can leave rules empty and get a nice
# NotImplementedError. A way to quickly spec out your parser rules?

$:.unshift File.dirname(__FILE__) + "/../lib"

require 'parslet'

class MyParser < Parslet::Parser
  rule(:empty) { }
end


MyParser.new.empty.parslet
