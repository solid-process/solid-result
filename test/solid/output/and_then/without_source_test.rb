# frozen_string_literal: true

require 'test_helper'

module Solid
  class OutputAndThenWithoutSourceTest < Minitest::Test
    test '#and_then does not execute the block if the result is a failure' do
      result =
        Output::Success
          .new(type: :one, value: { number: 1 })
          .and_then { Output::Failure(:two, number: 2) }
          .and_then { Output::Success(:three, number: 3) }
          .and_then { Output::Success(:four, number: 4) }

      assert result.failure?(:two)

      assert_equal({ number: 2 }, result.value)
    end

    test '#and_then executes the block if the result is a success' do
      result =
        Output::Success(:one, number: 1)
          .and_then { Output::Success(:two, number: 2) }
          .and_then { Output::Success(:three, number: 3) }
          .and_then { Output::Success(:four, number: 4) }

      assert result.success?(:four)

      assert_equal({ number: 4 }, result.value)
    end

    test '#and_then does not handle an exception raised in the block' do
      assert_raises(RuntimeError) do
        Output::Success(:one, number: 1)
          .and_then { Output::Success(:two, number: 2) }
          .and_then { raise 'boom' }
      end
    end

    test '#and_then raises an exception if the block does not return a solid output (regular object)' do
      error = assert_raises(Solid::Output::Error::UnexpectedOutcome) do
        Output::Success(:one, number: 1)
          .and_then { Output::Success(:two, number: 2) }
          .and_then { 3 }
      end

      assert_equal(
        'Unexpected outcome: 3. The block must return this object wrapped by ' \
        'Solid::Output::Success or Solid::Output::Failure',
        error.message
      )
    end

    test '#and_then raises an exception if the block does not return a solid output (Solid::Result)' do
      error = assert_raises(Solid::Output::Error::UnexpectedOutcome) do
        Output::Success(:one, number: 1)
          .and_then { Output::Success(:two, number: 2) }
          .and_then { Solid::Result::Success(:three, number: 3) }
      end

      assert_equal(
        'Unexpected outcome: #<Solid::Result::Success type=:three value={:number=>3}>. ' \
        'The block must return this object wrapped by Solid::Output::Success or Solid::Output::Failure',
        error.message
      )
    end
  end
end
