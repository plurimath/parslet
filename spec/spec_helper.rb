# frozen_string_literal: true

require_relative 'support/opal' if RUBY_ENGINE == 'opal'

require 'parslet'
require 'parslet/rig/rspec'
require 'parslet/atoms/visitor'
require 'parslet/export'

begin
  require 'ae'
rescue LoadError
  # AE not available
end

RSpec.configure do |config|
  # Allow both old and new syntax for backward compatibility
  config.expect_with :rspec do |expectations|
    expectations.syntax = %i[should expect]
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # Use rspec mocks
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  # Shared context and examples
  config.shared_context_metadata_behavior = :apply_to_host_groups

  # This is not a Rails project, so no Rails-specific configuration needed

  # Exclude other ruby versions by giving :ruby => '2.7' or :ruby => '3.0'
  config.filter_run_excluding ruby: lambda { |version|
    RUBY_VERSION !~ /^#{Regexp.escape(version.to_s)}/
  }

  # Run specs in random order to surface order dependencies
  config.order = :random
  Kernel.srand config.seed
end

def catch_failed_parse
  exception = nil
  begin
    yield
  rescue Parslet::ParseFailed => e
    exception = e
  end
  exception&.parse_failure_cause
end

def slet(name, &block)
  let(name, &block)
  subject(&block)
end
