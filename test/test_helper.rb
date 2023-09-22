# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'bcdd/result'

require 'minitest/autorun'

class Minitest::Test
  # Implementation based on:
  # https://github.com/rails/rails/blob/ac717d6/activesupport/lib/active_support/testing/declarative.rb
  def self.test(name, &block)
    test_name = "test_#{name.gsub(/\s+/, '_')}".to_sym
    defined = method_defined? test_name
    raise "#{test_name} is already defined in #{self}" if defined

    if block
      define_method(test_name, &block)
    else
      define_method(test_name) do
        flunk "No implementation provided for #{name}"
      end
    end
  end
end
