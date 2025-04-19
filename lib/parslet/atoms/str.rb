# Matches a string of characters. 
#
# Example: 
# 
#   str('foo') # matches 'foo'
#
class Parslet::Atoms::Str < Parslet::Atoms::Base
  attr_reader :str
  def initialize(str)
    super()

    @str = str.to_s
    @pat = Regexp.new(Regexp.escape(str))
    @len = str.size
  end

  def error_msgs
    @error_msgs ||= {
      premature: 'Premature end of input',
      failed: "Expected #{str.inspect}, but got "
    }
  end

  def lookahead?(source)
    source.lookahead?(@pat)
  end

  def compute_re
    return @re1 unless @re1.nil?
    @re1 = Regexp.compile(Regexp.escape(@str[0]))
  end

  def first_char_re
    compute_re
  end

  def try(source, context, consume_all)
    return succ(source.consume(@len)) if source.matches?(@pat)
    
    # Input ending early:
    return context.err(self, source, error_msgs[:premature]) \
      if source.chars_left<@len
    
    # Expected something, but got something else instead:  
    error_pos = source.pos  
    return context.err_at(
      self, source, 
      [error_msgs[:failed], source.consume(@len)], error_pos) 
  end
  
  def to_s_inner(prec)
    "'#{str}'"
  end
end

