# Custom RSpec matchers for Parslet structures
# These matchers handle the comparison of Parslet::Slice objects and nested structures

RSpec::Matchers.define :parse_as do |expected|
  match do |actual|
    normalize_parslet_structure(actual) == normalize_parslet_structure(expected)
  end

  failure_message do |actual|
    "expected #{normalize_parslet_structure(actual)} to parse as #{normalize_parslet_structure(expected)}"
  end

  failure_message_when_negated do |actual|
    "expected #{normalize_parslet_structure(actual)} not to parse as #{normalize_parslet_structure(expected)}"
  end

  def normalize_parslet_structure(obj)
    case obj
    when Hash
      obj.transform_values { |v| normalize_parslet_structure(v) }
    when Array
      obj.map { |item| normalize_parslet_structure(item) }
    when Parslet::Slice
      obj.to_s
    else
      obj
    end
  end
end

RSpec::Matchers.define :match_structure do |expected|
  match do |actual|
    deep_match(actual, expected)
  end

  failure_message do |actual|
    "expected structure to match:\n#{format_structure(expected)}\n\nbut got:\n#{format_structure(actual)}"
  end

  def deep_match(actual, expected)
    case expected
    when Hash
      return false unless actual.is_a?(Hash)
      expected.all? do |key, value|
        actual.key?(key) && deep_match(actual[key], value)
      end
    when Array
      return false unless actual.is_a?(Array)
      return false unless actual.length == expected.length
      actual.zip(expected).all? { |a, e| deep_match(a, e) }
    when String
      actual.to_s == expected
    when Symbol
      actual.to_s == expected.to_s
    when Class
      actual.is_a?(expected)
    else
      actual == expected
    end
  end

  def format_structure(obj, indent = 0)
    spaces = "  " * indent
    case obj
    when Hash
      if obj.empty?
        "{}"
      else
        "{\n" + obj.map { |k, v| "#{spaces}  #{k.inspect} => #{format_structure(v, indent + 1)}" }.join(",\n") + "\n#{spaces}}"
      end
    when Array
      if obj.empty?
        "[]"
      else
        "[\n" + obj.map { |item| "#{spaces}  #{format_structure(item, indent + 1)}" }.join(",\n") + "\n#{spaces}]"
      end
    when Parslet::Slice
      obj.to_s.inspect + " (Slice)"
    else
      obj.inspect
    end
  end
end

# Helper method to create expected structures more easily
def slice(str)
  str
end

def hash_with(**keys)
  keys
end

def array_of(*items)
  items
end
