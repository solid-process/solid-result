# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new(:test_configuration) do |t|
  t.libs += %w[lib test]

  t.test_files = FileList.new('test/**/configuration_test.rb')
end

Rake::TestTask.new(:test) do |t|
  t.libs += %w[lib test]

  t.test_files = FileList.new('test/**/*_test.rb')
end

require 'rubocop/rake_task'

RuboCop::RakeTask.new

task default: %i[test rubocop]
