#!/usr/bin/env ruby

# This example demonstrates the MiniLisp parser and transformer
# It reproduces the example from:
# http://thingsaaronmade.com/blog/a-quick-intro-to-writing-a-parser-using-treetop.html

require_relative '../spec/fixtures/examples/minilisp'
require 'pp'

# Create parser and transformer instances
parser = MiniLisp::Parser.new
transform = MiniLisp::Transform.new

# Parse a simple Lisp expression
lisp_code = %Q{
  (define test (lambda ()
    (begin
      (display "something")
      (display 1)
      (display 3.08))))
}

puts "Parsing MiniLisp code:"
puts lisp_code
puts "\n" + "="*50 + "\n"

begin
  # Parse the code
  result = parser.parse_with_debug(lisp_code)

  puts "Parse tree:"
  pp result
  puts "\n" + "-"*50 + "\n"

  # Transform the result
  if result
    transformed = transform.do(result)
    puts "Transformed result:"
    pp transformed
  end

rescue Parslet::ParseFailed => error
  puts "Parse failed:"
  puts error.parse_failure_cause.ascii_tree
end

puts "\nThis reduces the problem to the earlier work at:"
puts "http://github.com/kschiess/toylisp"
