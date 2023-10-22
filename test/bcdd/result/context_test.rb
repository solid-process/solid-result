# frozen_string_literal: true

require 'test_helper'

class BCDD::Result
  class ContextTest < Minitest::Test
    test 'is a BCDD::Result' do
      assert Context < BCDD::Result
    end

    test '#initialize value validation' do
      err = assert_raises(ArgumentError) { Context.new(type: :ok, value: nil) }

      assert_equal 'value must be a Hash', err.message
    end

    test '::Success()' do
      result = Context::Success(:ok)

      assert_equal(:ok, result.type)
      assert_equal({}, result.value)

      # ---

      result = Context::Success(:yes, number: 1)

      assert_equal(:yes, result.type)
      assert_equal({ number: 1 }, result.value)

      # ---

      err = assert_raises(ArgumentError) { Context::Success(:ok, nil) }

      assert_equal 'wrong number of arguments (given 2, expected 1)', err.message
    end

    test '::Failure()' do
      result = Context::Failure(:no)

      assert_equal(:no, result.type)
      assert_equal({}, result.value)

      # ---

      result = Context::Failure(:err, number: 0)

      assert_equal(:err, result.type)
      assert_equal({ number: 0 }, result.value)

      # ---

      err = assert_raises(ArgumentError) { Context::Failure(:ok, nil) }

      assert_equal 'wrong number of arguments (given 2, expected 1)', err.message
    end
  end
end
