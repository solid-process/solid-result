# frozen_string_literal: true

require 'test_helper'

class BCDD::Result
  class ContextAndThenWithoutSubjectTest < Minitest::Test
    test '#and_then does not execute the block if the result is a failure' do
      result =
        Context::Success
          .new(type: :one, value: { number: 1 })
          .and_then { Context::Failure(:two, number: 2) }
          .and_then { Context::Success(:three, number: 3) }
          .and_then { Context::Success(:four, number: 4) }

      assert result.failure?(:two)

      assert_equal({ number: 2 }, result.value)
    end

    test '#and_then executes the block if the result is a success' do
      result =
        Context::Success(:one, number: 1)
          .and_then { Context::Success(:two, number: 2) }
          .and_then { Context::Success(:three, number: 3) }
          .and_then { Context::Success(:four, number: 4) }

      assert result.success?(:four)

      assert_equal({ number: 4 }, result.value)
    end

    test '#and_then does not handle an exception raised in the block' do
      assert_raises(RuntimeError) do
        Context::Success(:one, number: 1)
          .and_then { Context::Success(:two, number: 2) }
          .and_then { raise 'boom' }
      end
    end

    test '#and_then raises an exception if the block does not return a result context (regular object)' do
      error = assert_raises(BCDD::Result::Context::Error::UnexpectedOutcome) do
        Context::Success(:one, number: 1)
          .and_then { Context::Success(:two, number: 2) }
          .and_then { 3 }
      end

      assert_equal(
        'Unexpected outcome: 3. The block must return this object wrapped by ' \
        'BCDD::Result::Context::Success or BCDD::Result::Context::Failure',
        error.message
      )
    end

    test '#and_then raises an exception if the block does not return a result context (BCDD::Result)' do
      error = assert_raises(BCDD::Result::Context::Error::UnexpectedOutcome) do
        Context::Success(:one, number: 1)
          .and_then { Context::Success(:two, number: 2) }
          .and_then { BCDD::Result::Success(:three, number: 3) }
      end

      assert_equal(
        'Unexpected outcome: #<BCDD::Result::Success type=:three value={:number=>3}>. ' \
        'The block must return this object wrapped by BCDD::Result::Context::Success or BCDD::Result::Context::Failure',
        error.message
      )
    end
  end
end
