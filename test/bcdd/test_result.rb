# frozen_string_literal: true

require 'test_helper'

class BCDD::TestResult < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::BCDD::Result::VERSION
  end

  def test_initialize_errors
    error = assert_raises(ArgumentError) { BCDD::Result.new(type: :ok) }

    assert_equal 'missing keyword: :value', error.message

    error = assert_raises(ArgumentError) { BCDD::Result.new(value: 1) }

    assert_equal 'missing keyword: :type', error.message

    error = assert_raises(ArgumentError) { BCDD::Result.new }

    assert_equal 'missing keywords: :type, :value', error.message
  end

  def test_value
    assert_equal 1, BCDD::Result.new(type: :ok, value: 1).value
    assert_nil BCDD::Result.new(type: :ok, value: nil).value
  end

  def test_type
    assert_equal :ok, BCDD::Result.new(type: :ok, value: 1).type
    assert_equal :ok, BCDD::Result.new(type: :ok, value: nil).type

    assert_equal :err, BCDD::Result.new(type: :err, value: 0).type
    assert_equal :err, BCDD::Result.new(type: :err, value: nil).type
  end
end
