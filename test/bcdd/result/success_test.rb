# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::SuccessTest < Minitest::Test
  test 'is a BCDD::Result' do
    assert BCDD::Result::Success < BCDD::Result
  end

  test '#success? without receiving a type' do
    result = BCDD::Result::Success.new(type: :good, value: nil)

    assert_predicate result, :success?
  end

  test '#success? receiving a type' do
    result = BCDD::Result::Success.new(type: :good, value: nil)

    assert result.success?(:good)

    refute result.success?(:ok)
  end

  test '#failure? should return false' do
    result = BCDD::Result::Success.new(type: :ok, value: nil)

    refute_predicate result, :failure?

    refute result.failure?(:ok)
  end

  test '#value_or' do
    result = BCDD::Result::Success.new(type: :ok, value: 1)

    assert_equal(1, result.value_or { 0 })
  end
end
