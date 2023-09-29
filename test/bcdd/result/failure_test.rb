# frozen_string_literal: true

require 'test_helper'

class BCDD::Result
  class FailureTest < Minitest::Test
    test 'is a BCDD::Result' do
      assert Failure < BCDD::Result
    end

    test '#success? should return false' do
      result = Failure.new(type: :err, value: nil)

      refute_predicate result, :success?

      refute result.success?(:err)
    end

    test '#failure? without receiving a type/argument' do
      result = Failure.new(type: :bad, value: nil)

      assert_predicate result, :failure?
    end

    test '#failure? receiving a type' do
      result = Failure.new(type: :bad, value: nil)

      assert result.failure?(:bad)

      refute result.failure?(:err)
    end

    test '#value_or' do
      result = Failure.new(type: :err, value: nil)

      assert_equal(0, result.value_or { 0 })
    end

    test '#inspect' do
      result = Failure.new(type: :err, value: 2)

      assert_equal '#<BCDD::Result::Failure type=:err value=2>', result.inspect
    end
  end
end
