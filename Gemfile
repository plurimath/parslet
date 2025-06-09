# frozen_string_literal: true

source "https://rubygems.org"

gemspec

gem "base64"
gem "benchmark-ips"
gem "mathn" # For the mathn compatibility test only
gem "racc"
gem "rake"
gem "rdoc"
gem "rspec"
gem "rubocop"
gem "rubocop-performance"
gem "rubocop-rspec"

# AE is needed for Opal compatibility, see spec/support/opal.rb.erb
gem "ae"
gem "opal", path: "vendor/opal"
gem "opal-rspec", path: 'vendor/opal-rspec', ref: 'fcc58ba', require: false
gem "opal-sprockets", require: false #, path: 'vendor/opal-sprockets'
gem "qed"
