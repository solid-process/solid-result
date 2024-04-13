# frozen_string_literal: true

require 'test_helper'

class Solid::Result
  class OnFailureHookTest < Minitest::Test
    test '#on_failure returns the result itself' do
      result = Failure.new(type: :error, value: 1)

      r1 = result
           .on_failure(:okay) { |value| assert_equal(1, value) }

      r2 = result
           .on_failure(:okay) { |value| assert_equal(1, value) }
           .on_failure(:okay) { |value| assert_equal(1, value) }

      assert_same result, r1
      assert_same result, r2
    end

    test '#on_failure without receving types/arguments' do
      number = 0

      result = Failure.new(type: :error, value: 1)

      result
        .on_failure { |value| number += value }
        .on_failure { |value| number += value }

      result.on_failure { |value| number += value }

      assert_equal 3, number
    end

    test '#on_failure with a single type' do
      number = 0

      result = Failure.new(type: :error, value: 1)

      result
        .on_failure { |value| number += value }
        .on_failure(:error) { |value| number += value }
        .on_failure(:error) { |value| number += value }
        .on_failure(:wont_count) { |value| number += value }
        .on_failure { |value| number += value }

      assert_equal 4, number
    end

    test '#on_failure with multiple types' do
      number = 0

      result = Failure.new(type: :err, value: 1)

      result
        .on_failure(:not_okay, :err) { |value| number += value }
        .on_failure { |value| number += value }
        .on_failure(:err) { |value| number += value }
        .on_failure(:not_okay, :wont_count) { |value| number += value }
        .on_failure(:wont_count) { |value| number += value }
        .on_failure { |value| number += value }

      assert_equal 4, number
    end

    test '#on_failure without matching types' do
      number = 0

      result = Failure.new(type: :err, value: 1)

      result
        .on_failure(:not_okay) { |value| number += value }
        .on_failure(:error) { |value| number += value }

      assert_equal 0, number
    end

    test '#on_failure is ignored by successes' do
      number = 0

      result = Success.new(type: :ok, value: 1)

      result
        .on_failure { |value| number += value }
        .on_failure(:ok) { |value| number += value }

      assert_equal 0, number
    end
  end
end
