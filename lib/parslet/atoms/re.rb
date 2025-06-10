# Matches a special kind of regular expression that only ever matches one
# character at a time. Useful members of this family are: <code>character
# ranges, \\w, \\d, \\r, \\n, ...</code>
#
# Example: 
#
#   match('[a-z]')  # matches a-z
#   match('\s')     # like regexps: matches space characters
#
class Parslet::Atoms::Re < Parslet::Atoms::Base
  attr_reader :match, :re
  def initialize(match)
    super()

    @match = match.to_s
    @re    = Regexp.new(self.match, Regexp::MULTILINE)
  end

  def error_msgs
    @error_msgs ||= {
      premature: 'Premature end of input',
      failed: "Failed to match #{match.inspect[1..-2]}"
    }
  end

  def lookahead?(source)
    source.lookahead?(@re)
  end

  def compute_re
    return @re1 unless @re1.nil?
    re = EMPTY_RE
    m = @match
    re = Regexp.compile(m[0..4]) if m[0] == '[' and m[3] == ']'
    @re1 = re
  end

  def first_char_re
    compute_re
  end

  def try(source, context, consume_all)
    return succ(source.consume(1)) if source.matches?(@re)
    
    # No string could be read
    return context.err(self, source, error_msgs[:premature]) \
      if source.chars_left < 1
        
    # No match
    return context.err(self, source, error_msgs[:failed])
  end

  def to_s_inner(prec)
    match.inspect[1..-2]
  end
end

