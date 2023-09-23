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
end
