
# Alternative during matching. Contains a list of parslets that is tried each
# one in turn. Only fails if all alternatives fail. 
#
# Example: 
# 
#   str('a') | str('b')   # matches either 'a' or 'b'
#
class Parslet::Atoms::Alternative < Parslet::Atoms::Base
  attr_reader :alternatives
  
  # Constructs an Alternative instance using all given parslets in the order
  # given. This is what happens if you call '|' on existing parslets, like 
  # this: 
  #
  #   str('a') | str('b')
  #
  def initialize(*alternatives)
    super()
    
    @alternatives = alternatives
  end

  #---
  # Don't construct a hanging tree of Alternative parslets, instead store them
  # all here. This reduces the number of objects created.
  #+++
  def |(parslet)
    self.class.new(*@alternatives + [parslet])
  end

  def error_msg
    @error_msg ||= "Expected one of #{alternatives.inspect}"
  end

  # Lazy init
  # We can't do this in constructor because Parslet::Atoms::Alternative is built incrementally
  def apply_group_optimization?
    return @grouped_optimization unless @grouped_optimization.nil?

    alternatives = @alternatives
    @alternatives_by_char = {}
    @grouped_optimization = false

    # Try to group the alternatives by the first character
    # This way we can skip multiple alternatives in one lookahead
    # Only apply this optimization to huge alternatives (for now?)
    if alternatives.size >= 10
      non_empty = 0
      alternatives.each do | a|
        re = a.first_char_re
        @alternatives_by_char[re] ||= []
        @alternatives_by_char[re] << a
        non_empty += 1 if re != EMPTY_RE
      end
      @grouped_optimization = non_empty >= alternatives.size / 2
    end
  end

  def lookahead?(source)
    # We need to stop the recursive lookahead at some point, otherwise it might go too deep
    true
  end

  def try(source, context, consume_all)
    if self.debug_mode
      errors = alternatives.map { |a|
        success, value = result = a.apply(source, context, consume_all)
        return result if success

        # Aggregate all errors
        value
      }

      # If we reach this point, all alternatives have failed.
      return context.err(self, source, error_msg, errors)
    end

    # TODO: this optimization should be disabled if the order of @alternatives matters
    if apply_group_optimization?
      @alternatives_by_char.each_key do |ch|
        char_alternatives = @alternatives_by_char[ch]
        if source.lookahead?(ch)
          char_alternatives.each { |a|
            next unless a.lookahead?(source)

            success, _ = result = a.apply(source, context, consume_all)
            return result if success
          }
        end
      end
    else
      alternatives.each { |a|
        # Instead of entering the more expensive apply() method,
        # we attempt to look ahead and continue to the next alternative if there's no match
        # The `Constants.precompile_constants` alternative has over 3k options
        next unless a.lookahead?(source)

        success, _ = result = a.apply(source, context, consume_all)
        return result if success
      }
    end

    # If we reach this point, all alternatives have failed.
    context.err(self, source, error_msg)
  end

  precedence ALTERNATE
  def to_s_inner(prec)
    if self.debug_mode
      alternatives.map { |a| a.to_s(prec) }.join(' / ')
    else
      # Don't dump all the alternatives, it takes too much time
      limit = 5
      items = alternatives.first(limit)
                          .map { |a| "#{a.class}[#{a.to_s(prec).gsub("\n", " ")}]" }
                          .join(' / ')

      if alternatives.size > limit
        items += " and (#{alternatives.size - limit}) more"
      end

      items
    end
  end
end
