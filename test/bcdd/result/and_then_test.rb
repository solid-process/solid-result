# frozen_string_literal: true

require 'test_helper'

module BCDD::Result
  class AndThenTest < Minitest::Test
    test '#and_then does not execute the block if the result is a failure' do
      result =
        Success
        .new(type: :one, value: 1)
        .and_then { Failure.new(type: :two, value: 2) }
        .and_then { Success.new(type: :three, value: 3) }
        .and_then { Success.new(type: :four, value: 4) }

      assert_predicate result, :failure?
      assert_equal :two, result.type
      assert_equal 2, result.value
    end

    test '#and_then executes the block if the result is a success' do
      result =
        Success
        .new(type: :one, value: 1)
        .and_then { Success.new(type: :two, value: 2) }
        .and_then { Success.new(type: :three, value: 3) }
        .and_then { Success.new(type: :four, value: 4) }

      assert_predicate result, :success?
      assert_equal :four, result.type
      assert_equal 4, result.value
    end

    test '#and_then does not handle an exception raised in the block' do
      assert_raises(RuntimeError) do
        Success
          .new(type: :one, value: 1)
          .and_then { Success.new(type: :two, value: 2) }
          .and_then { raise 'boom' }
      end
    end
  end
end
