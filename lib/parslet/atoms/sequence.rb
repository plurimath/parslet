# A sequence of parslets, matched from left to right. Denoted by '>>'
#
# Example: 
#
#   str('a') >> str('b')  # matches 'a', then 'b'
#
class Parslet::Atoms::Sequence < Parslet::Atoms::Base
  attr_reader :parslets
  def initialize(*parslets)
    super()

    @parslets = parslets
  end

  def error_msgs
    @error_msgs ||= {
      failed: "Failed to match sequence (<omited for performance reasons>)"
    }
  end
  
  def >>(parslet)
    self.class.new(* @parslets+[parslet])
  end

  def is_combined_re
    return @is_combined unless @is_combined.nil?

    return @is_combined = false if @parslets.length < 2
    @is_combined = false

    first_are_re = @parslets[0...-1].all? { | parslet | parslet.is_a?(Parslet::Atoms::Re) }
    if first_are_re
      last_re = @parslets[-1].is_a?(Parslet::Atoms::Re)
      last_lookahead = @parslets[-1].is_a?(Parslet::Atoms::Lookahead) && @parslets[-1].bound_parslet.is_a?(Parslet::Atoms::Re)
      if last_lookahead or last_re
        combined = @parslets.map { |p| p.match}.join
        @combined_re = Regexp.compile(combined)
        @is_combined = true
      end
    end
    @is_combined
  end

  def lookahead?(source)
    return source.lookahead?(@combined_re) if is_combined_re
    parslets[0].lookahead?(source)
  end

  def first_char_re
    parslets[0].first_char_re
  end

  def try(source, context, consume_all)
    # Lazy init array
    result = nil

    parslets.each_with_index do |p, idx|
      unless p.lookahead?(source)
        return context.err(self, source, error_msgs[:failed])
      end

      child_consume_all = consume_all && (idx == parslets.size-1)
      success, value = p.apply(source, context, child_consume_all)

      unless success
        return context.err(self, source, error_msgs[:failed])
      end

      if result.nil?
        result = Array.new(parslets.size + 1)
        result[0] = :sequence
      end
      result[idx+1] = value
    end

    succ(result)
  end
      
  precedence SEQUENCE
  def to_s_inner(prec)
    parslets.map { |p| p.to_s(prec) }.join(' ')
  end
end
