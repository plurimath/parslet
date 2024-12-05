
# Encapsules the concept of a position inside a string.
#
class Parslet::Position
  attr_reader :bytepos

  include Comparable

  def initialize string, bytepos, charpos
    @string = string
    @bytepos = bytepos
    @charpos = charpos
  end

  def charpos
    @charpos
  end

  def <=> b
    self.bytepos <=> b.bytepos
  end
end
