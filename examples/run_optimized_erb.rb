#!/usr/bin/env ruby

# This example demonstrates optimized ERB template parsing
# Shows performance optimizations for parsing large ERB templates

require_relative '../spec/fixtures/examples/optimized_erb'
require 'pp'

# Sample ERB template content (inline for demonstration)
erb_template = <<~ERB
  <html>
    <head>
      <title><%= @title %></title>
    </head>
    <body>
      <h1><%= @heading %></h1>
      <% @items.each do |item| %>
        <div class="item">
          <h2><%= item.name %></h2>
          <p><%= item.description %></p>
          <% if item.featured? %>
            <span class="featured">Featured!</span>
          <% end %>
        </div>
      <% end %>

      <footer>
        <%= render_footer %>
      </footer>
    </body>
  </html>
ERB

puts "Optimized ERB Parser Demo"
puts "Demonstrates performance optimizations for parsing large ERB templates"
puts "\n" + "="*60 + "\n"

# Test different parsing approaches
parsing_methods = [
  { name: "Standard parsing", method: :parse_with_standard },
  { name: "Greedy blind parsing", method: :parse_with_greedy_blind },
  { name: "Greedy non-blind parsing", method: :parse_with_greedy_non_blind }
]

parsing_methods.each do |approach|
  puts "Testing #{approach[:name]}:"

  begin
    start_time = Time.now
    result = OptimizedErbExample.send(approach[:method], erb_template)
    end_time = Time.now

    puts "  Parse time: #{((end_time - start_time) * 1000).round(2)}ms"
    puts "  Parse tree size: #{result.to_s.length} characters"
    puts "  Status: ✓ Parse successful"

  rescue Parslet::ParseFailed => error
    puts "  Status: ✗ Parse failed"
    puts "  Error: #{error.message}"
  rescue => error
    puts "  Status: ✗ Error"
    puts "  Error: #{error.message}"
  end

  puts "-" * 50
end

puts "\nThis example demonstrates:"
puts "- Performance optimization techniques for ERB parsing"
puts "- Greedy vs non-greedy parsing strategies"
puts "- Blind vs non-blind parsing approaches"
puts "- Performance measurement and comparison"
puts "- Handling large template files efficiently"
