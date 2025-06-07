# Basically just demonstrates that you can leave rules empty and get a nice
# NotImplementedError. A way to quickly spec out your parser rules?

require 'parslet'

module EmptyExample
  class MyParser < Parslet::Parser
    rule(:empty) { }
  end
end
