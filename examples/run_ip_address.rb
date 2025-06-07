#!/usr/bin/env ruby

# This example demonstrates IP address parsing (IPv4 and IPv6)
# Shows how to parse and validate different IP address formats

require_relative '../spec/fixtures/examples/ip_address'
require 'pp'

# Test IP addresses
test_cases = [
  # Valid IPv4
  "192.168.1.1",
  "10.0.0.1",
  "255.255.255.255",
  "0.0.0.0",

  # Valid IPv6
  "2001:0db8:85a3:0000:0000:8a2e:0370:7334",
  "2001:db8:85a3::8a2e:370:7334",
  "::1",
  "fe80::1",

  # Invalid cases
  "256.1.1.1",
  "192.168.1",
  "not.an.ip.address"
]

puts "IP Address Parser Demo"
puts "Parses and validates IPv4 and IPv6 addresses"
puts "\n" + "="*50 + "\n"

test_cases.each do |ip|
  puts "Testing: #{ip}"

  begin
    result = IPAddress.parse(ip)
    puts "  Parse tree:"
    pp result
    puts "  Status: ✓ Valid IP address"

  rescue Parslet::ParseFailed => error
    puts "  Status: ✗ Invalid IP address"
    puts "  Error: Parse failed"
  rescue => error
    puts "  Status: ✗ Error"
    puts "  Error: #{error.message}"
  end

  puts "-" * 40
end

puts "\nThis parser supports:"
puts "- IPv4 addresses (dotted decimal notation)"
puts "- IPv6 addresses (hexadecimal with colons)"
puts "- IPv6 shorthand notation (::)"
puts "- Proper validation of address ranges"
