# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rdoc/task'

begin
  require 'opal/rspec/rake_task'
rescue LoadError
  # Opal not available
end

desc 'Run all tests'
RSpec::Core::RakeTask.new(:spec)

namespace :spec do
  desc 'Run unit tests only'
  RSpec::Core::RakeTask.new(:unit) do |task|
    task.pattern = 'spec/parslet/**/*_spec.rb'
  end

  if defined?(Opal::RSpec::RakeTask)
    desc 'Run Opal (JavaScript) tests'
    Opal::RSpec::RakeTask.new(:opal)
  end
end

RDoc::Task.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = 'Plurimath Parslet'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.adoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc 'Print LOC statistics'
task :stat do
  %w[lib spec example].each do |dir|
    next unless Dir.exist?(dir)

    loc = `find #{dir} -name "*.rb" | xargs wc -l | grep 'total'`.split.first.to_i
    printf("%20s %d\n", dir, loc)
  end
end

task default: :spec
