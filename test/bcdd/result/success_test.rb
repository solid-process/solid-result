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

  test '#==' do
    result = BCDD::Result::Success.new(type: :ok, value: 2)

    assert_equal result, BCDD::Result::Success.new(type: :ok, value: 2)

    refute_equal result, BCDD::Result::Success.new(type: :ok, value: 3)
    refute_equal result, BCDD::Result::Success.new(type: :yes, value: 2)
    refute_equal result, BCDD::Result::Failure.new(type: :ok, value: 2)
    refute_equal result, BCDD::Result.new(type: :ok, value: 2)
  end

  test 'eql?' do
    result = BCDD::Result::Success.new(type: :yes, value: 'yes')

    assert result.eql?(BCDD::Result::Success.new(type: :yes, value: 'yes'))

    refute result.eql?(BCDD::Result::Success.new(type: :ok, value: 3))
    refute result.eql?(BCDD::Result::Success.new(type: :yes, value: 2))
    refute result.eql?(BCDD::Result::Failure.new(type: :ok, value: 2))
    refute result.eql?(BCDD::Result.new(type: :ok, value: 2))
  end
end
