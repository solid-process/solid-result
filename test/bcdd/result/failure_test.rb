# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::FailureTest < Minitest::Test
  test 'is a BCDD::Result' do
    assert BCDD::Result::Failure < BCDD::Result
  end

  test '#success? should return false' do
    result = BCDD::Result::Failure.new(type: :err, value: nil)

    refute_predicate result, :success?

    refute result.success?(:err)
  end

  test '#failure? without receiving a type' do
    result = BCDD::Result::Failure.new(type: :bad, value: nil)

    assert_predicate result, :failure?
  end

  test '#failure? receiving a type' do
    result = BCDD::Result::Failure.new(type: :bad, value: nil)

    assert result.failure?(:bad)

    refute result.failure?(:err)
  end

  test '#value_or' do
    result = BCDD::Result::Failure.new(type: :err, value: nil)

    assert_equal(0, result.value_or { 0 })
  end

  test '#==' do
    result = BCDD::Result::Failure.new(type: :err, value: 2)

    assert_equal result, BCDD::Result::Failure.new(type: :err, value: 2)

    refute_equal result, BCDD::Result::Failure.new(type: :err, value: 3)
    refute_equal result, BCDD::Result::Failure.new(type: :no, value: 2)
    refute_equal result, BCDD::Result::Success.new(type: :err, value: 2)
    refute_equal result, BCDD::Result.new(type: :err, value: 2)
  end

  test 'eql?' do
    result = BCDD::Result::Failure.new(type: :no, value: 'no')

    assert result.eql?(BCDD::Result::Failure.new(type: :no, value: 'no'))

    refute result.eql?(BCDD::Result::Failure.new(type: :err, value: 3))
    refute result.eql?(BCDD::Result::Failure.new(type: :no, value: 2))
    refute result.eql?(BCDD::Result::Success.new(type: :err, value: 2))
    refute result.eql?(BCDD::Result.new(type: :err, value: 2))
  end

  test '#hash' do
    result = BCDD::Result::Failure.new(type: :err, value: 2)

    assert_equal result.hash, BCDD::Result::Failure.new(type: :err, value: 2).hash

    refute_equal result.hash, BCDD::Result::Success.new(type: :err, value: 2).hash
    refute_equal result.hash, BCDD::Result.new(type: :err, value: 2).hash
  end
end
