# frozen_string_literal: true

require 'bundler/inline'

$LOAD_PATH.unshift(__dir__)

gemfile do
  source 'https://rubygems.org'

  gem 'sqlite3', '~> 1.7'
  gem 'bcrypt', '~> 3.1.20'
  gem 'activerecord', '~> 7.1', '>= 7.1.3', require: 'active_record'
  gem 'bcdd-result', path: '../../'
end

require 'active_support/all'
