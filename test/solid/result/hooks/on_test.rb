# frozen_string_literal: true

require 'test_helper'

class Solid::Result
  class OnHookTest < Minitest::Test
    test '#on returns the result itself' do
      result = Success.new(type: :okay, value: 1)

      r1 = result.on(:okay) { |value| assert_equal(1, value) }

      r2 =
        result
        .on(:okay) { |value| assert_equal(1, value) }
        .on(:okay) { |value| assert_equal(1, value) }

      assert_same result, r1
      assert_same result, r2
    end

    test '#on works with successes or failures' do
      number = 0

      success = Success.new(type: :foo, value: 1)
      failure = Failure.new(type: :foo, value: 2)

      success.on(:foo) { |value| number += value }
      failure.on(:foo) { |value| number += value }

      assert_equal 3, number
    end

    test '#on without receving types/arguments' do
      number = 0

      result = Success.new(type: :okay, value: 1)

      error = assert_raises(Solid::Result::Error::MissingTypeArgument) do
        result.on { |value| number += value }
      end

      assert_equal(
        'A type (argument) is required to invoke the #on/#on_type method',
        error.message
      )
    end

    test '#on with a single type' do
      number = 0

      result = Success.new(type: :okay, value: 1)

      result
        .on(:okay) { |value| number += value }
        .on(:ok) { |value| number += value }

      assert_equal 1, number
    end

    test '#on with multiple types' do
      number = 0

      result = Success.new(type: :ok, value: 1)

      result
        .on(:ok) { |value| number += value }
        .on(:okay, :ok) { |value| number += value }

      assert_equal 2, number
    end

    test '#on without matching types' do
      number = 0

      result = Success.new(type: :ok, value: 1)

      result
        .on(:okay) { |value| number += value }
        .on(:err) { |value| number += value }

      assert_equal 0, number
    end
  end
end
