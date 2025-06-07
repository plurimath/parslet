# encoding: UTF-8

# A small example contributed by John Mettraux (jmettraux) that demonstrates
# working with Unicode. This only works on Ruby 1.9.

require 'parslet'

module SentenceExample
  class MyParser < Parslet::Parser
    rule(:sentence) { (match('[^。]').repeat(1) >> str("。")).as(:sentence) }
    rule(:sentences) { sentence.repeat }
    root(:sentences)
  end

  class Transformer < Parslet::Transform
    rule(:sentence => simple(:sen)) { sen.to_s }
  end
end
