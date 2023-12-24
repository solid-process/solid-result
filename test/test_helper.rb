# frozen_string_literal: true

require 'simplecov'

SimpleCov.start do
  enable_coverage :branch

  add_filter '_test.rb'
end

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'bcdd/result'

require 'minitest/autorun'

require 'mocha/minitest'

class Minitest::Test
  # Implementation based on:
  # https://github.com/rails/rails/blob/ac717d6/activesupport/lib/active_support/testing/declarative.rb
  def self.test(name, &block)
    test_name = :"test_#{name.gsub(/\s+/, '_')}"

    method_defined?(test_name) and raise "#{test_name} is already defined in #{self}"

    if block
      define_method(test_name, &block)
    else
      define_method(test_name) do
        flunk "No implementation provided for #{name}"
      end
    end
  end
end

module Regexps
  UUID = /\A[0-9a-f]{8}\b-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-\b[0-9a-f]{12}\z/.freeze
end

module HashSchemaAssertions
  def assert_hash_schema!(spec, hash, ignore_keys: [])
    keys_to_compare = hash.keys - ignore_keys

    assert_collection_diff(spec.keys, keys_to_compare, context_message: nil)

    spec.each { |key, expected| assert_hash_schema_item(expected, key, hash[key]) }
  end

  def assert_hash_schema(spec, hash)
    keys_diff = spec.keys - hash.keys
    ignore_keys = hash.keys - spec.keys

    assert_empty(keys_diff, "Keys expected in the diff #{keys_diff}")

    assert_hash_schema!(spec, hash, ignore_keys: ignore_keys)
  end

  private

  ErrorMessage = ->(key, extra = nil) { "The key #{key.inspect} has an invalid value. #{extra}".chomp(' ') }

  def assert_hash_schema_item(expected, key, value)
    case expected
    when Hash then assert_hash_schema!(expected, value)
    when Proc then assert(expected.call(value), ErrorMessage[key])
    when Regexp then assert_match(expected, value, ErrorMessage[key])
    when Module then assert_kind_of(expected, value, ErrorMessage[key])
    when NilClass then assert_nil(value, ErrorMessage[key])
    when Array, Set then assert_hash_schema_item_collection(expected, value, ErrorMessage[key])
    else
      assert_equal(expected, value, ErrorMessage[key])
    end
  end

  def assert_hash_schema_item_collection(expected, value, error_message)
    assert_collection_diff(expected.to_a, value.to_a, context_message: error_message)

    expected.each do |item|
      item.is_a?(Hash) ? assert_hash_schema!(item, value) : assert_includes(value, item, error_message)
    end
  end

  def assert_collection_diff(expected, actual, context_message:)
    context = "(#{context_message}) " if context_message

    actual_diff = actual - expected
    expected_diff = expected - actual

    assert_empty(actual_diff, "#{context}Keys expected in the diff: #{actual_diff}")
    assert_empty(expected_diff, "#{context}Keys not expected in the diff: #{expected_diff}")
  end
end

module BCDDResultTransitionAssertions
  include HashSchemaAssertions

  def assert_empty_transitions(result, version: 1)
    assert_transitions(result, size: 0, version: version)

    assert_predicate(result.transitions, :frozen?)
    assert_predicate(result.transitions[:records], :frozen?)
  end

  def assert_transitions(result, size:, version: 1)
    assert_instance_of(Hash, result.transitions)
    assert_equal(%i[records version], result.transitions.keys.sort)

    assert_equal(size, result.transitions[:records].size)
    assert_equal(version, result.transitions[:version])
  end

  def assert_transition_record(result, index, options)
    transition = result.transitions[:records][index]

    root, parent, current, result = options.fetch_values(:root, :parent, :current, :result)

    and_then = options.fetch(:and_then) { ->(value) { value.is_a?(::Hash) && value.empty? } }

    time = options.fetch(:time) { ->(value) { value.is_a?(::Time) && value.utc? } }

    assert_hash_schema!(
      { root: root, parent: parent, current: current, result: result, and_then: and_then, time: time },
      transition
    )
  end
end
