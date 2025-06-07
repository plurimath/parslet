#!/usr/bin/env ruby

# This example demonstrates sentence parsing
# Shows how to parse natural language sentences with grammar rules

require_relative '../spec/fixtures/examples/sentence'
require 'pp'

# Create parser instance
parser = SentenceExample::Parser.new

# Test sentences
test_cases = [
  "The cat sat on the mat",
  "A dog runs quickly",
  "Birds fly high",
  "The quick brown fox jumps",
  "Students study hard",
  "Invalid sentence structure"
]

puts "Sentence Parser Demo"
puts "Demonstrates parsing natural language sentences with grammar rules"
puts "\n" + "="*60 + "\n"

test_cases.each do |sentence|
  puts "Sentence: '#{sentence}'"

  begin
    result = parser.parse(sentence)
    puts "  Parse tree:"
    pp result
    puts "  Status: ✓ Valid sentence structure"

  rescue Parslet::ParseFailed => error
    puts "  Status: ✗ Invalid sentence structure"
    puts "  Error: Parse failed"
  end

  puts "-" * 50
end

puts "\nThis parser recognizes:"
puts "- Articles (the, a, an)"
puts "- Nouns and verbs"
puts "- Adjectives and adverbs"
puts "- Basic sentence structure patterns"
puts "- Subject-verb-object relationships"
