# frozen_string_literal: true

require 'test_helper'

module BCDD::Result
  class HooksOnTest < Minitest::Test
    test '#on' do
      result = Success.new(type: :okay, value: 1)

      r = result.on(:okay) { |value| assert_equal(1, value) }

      assert_same result, r
    end

    test '#on without receving types/arguments' do
      number = 0

      result = Success.new(type: :okay, value: 1)

      error = assert_raises(BCDD::Result::Error::MissingTypeArgument) do
        result.on { |value| number += value }
      end

      assert_equal 'a type must be defined', error.message
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

    test '#on matches the type independent of the result kind' do
      number = 0

      success = Success.new(type: :foo, value: 1)
      failure = Failure.new(type: :foo, value: 2)

      success.on(:foo) { |value| number += value }
      failure.on(:foo) { |value| number += value }

      assert_equal 3, number
    end
  end
end
