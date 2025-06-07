#!/usr/bin/env ruby

# This example demonstrates email address parsing
# Shows how to parse and validate email addresses with various formats

require_relative '../spec/fixtures/examples/email_parser'
require 'pp'

# Create parser instance
parser = EmailParser.new

# Test email addresses
test_emails = [
  "user@example.com",
  "test.email@domain.org",
  "user+tag@example.co.uk",
  "firstname.lastname@company.com",
  "user123@test-domain.net",
  "invalid.email",
  "@missing-user.com",
  "user@",
  "user@domain",
  "user.name@sub.domain.example.com"
]

puts "Email Address Parser Demo"
puts "Demonstrates parsing and validation of email addresses"
puts "\n" + "="*50 + "\n"

test_emails.each do |email|
  puts "Email: #{email}"

  begin
    result = parser.parse(email)
    puts "  Parse tree:"
    pp result
    puts "  Status: ✓ Valid email address"

  rescue Parslet::ParseFailed => error
    puts "  Status: ✗ Invalid email address"
    puts "  Error: Parse failed"
  end

  puts "-" * 40
end

puts "\nThis email parser supports:"
puts "- Standard email format (user@domain.tld)"
puts "- Dots in usernames and domains"
puts "- Plus signs for email tagging"
puts "- Hyphens in domain names"
puts "- Multiple subdomain levels"
puts "- Various top-level domains"
