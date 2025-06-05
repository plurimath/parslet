# frozen_string_literal: true

require_relative 'lib/parslet/version'

Gem::Specification.new do |spec|
  spec.name = 'plurimath-parslet'
  spec.version = Parslet::VERSION
  spec.platform = Gem::Platform::RUBY

  spec.authors = ['Kaspar Schiess', 'Ribose Inc.']
  spec.email = ['open.source@ribose.com']

  spec.summary = 'Parser construction library with great error reporting in Ruby.'
  spec.description = 'A small Ruby library for constructing parsers in the PEG (Parsing Expression Grammar) fashion. ' \
                     'This is a fork of the original parslet gem with Opal (JavaScript-based Ruby) compatibility.'
  spec.homepage = 'https://github.com/plurimath/plurimath-parslet'
  spec.license = 'MIT'

  spec.metadata = {
    'bug_tracker_uri' => 'https://github.com/plurimath/plurimath-parslet/issues',
    'changelog_uri' => 'https://github.com/plurimath/plurimath-parslet/blob/main/HISTORY.txt',
    'documentation_uri' => 'https://kschiess.github.io/parslet/',
    'homepage_uri' => 'https://github.com/plurimath/plurimath-parslet',
    'source_code_uri' => 'https://github.com/plurimath/plurimath-parslet',
  }

  spec.files = Dir.glob('{lib,spec,example}/**/*') + %w[
    HISTORY.txt
    LICENSE
    Rakefile
    README.adoc
    plurimath-parslet.gemspec
  ]
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.7.0'

  spec.add_development_dependency 'opal', '~> 1.8'
  spec.add_development_dependency 'opal-rspec', '~> 1.0'
  spec.add_development_dependency 'opal-sprockets', '~> 1.0'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rdoc', '~> 6.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
