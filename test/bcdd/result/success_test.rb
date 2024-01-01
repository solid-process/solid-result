# frozen_string_literal: true

require 'test_helper'

class BCDD::Result
  class SuccessTest < Minitest::Test
    test 'is a BCDD::Result' do
      assert Success < BCDD::Result
    end

    test 'has BCDD::Result::Success::Methods' do
      assert Success < BCDD::Result::Success::Methods
    end

    test '#terminal?' do
      result = Success.new(type: :ok, value: nil)

      refute_predicate result, :terminal?
    end

    test '#success? without receiving a type/argument' do
      result = Success.new(type: :good, value: nil)

      assert_predicate result, :success?
    end

    test '#success? receiving a type' do
      result = Success.new(type: :good, value: nil)

      assert result.success?(:good)

      refute result.success?(:ok)
    end

    test '#failure? should return false' do
      result = Success.new(type: :ok, value: nil)

      refute_predicate result, :failure?

      refute result.failure?(:ok)
    end

    test '#value_or' do
      result = Success.new(type: :ok, value: 1)

      assert_equal(1, result.value_or { 0 })
    end

    test '#inspect' do
      result = Success.new(type: :ok, value: 2)

      assert_equal '#<BCDD::Result::Success type=:ok value=2>', result.inspect
    end
  end
end
