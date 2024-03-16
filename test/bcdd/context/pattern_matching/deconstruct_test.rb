# frozen_string_literal: true

require 'test_helper'

class BCDD::Context::PatternMatchingDeconstructTest < Minitest::Test
  Divide = ->(arg1, arg2) do
    arg1.is_a?(::Numeric) or return BCDD::Context::Failure(:invalid_arg, err: 'arg1 must be numeric')
    arg2.is_a?(::Numeric) or return BCDD::Context::Failure(:invalid_arg, err: 'arg2 must be numeric')

    return BCDD::Context::Failure(:division_by_zero, err: 'arg2 must not be zero') if arg2.zero?

    BCDD::Context::Success(:division_completed, num: arg1 / arg2)
  end

  test '#deconstruct success' do
    result = Divide.call(10, 2)

    assert_equal [:division_completed, { num: 5 }], result.deconstruct

    case result
    in BCDD::Failure[_, _]
      raise
    in BCDD::Success[:division_completed, {num: value}]
      assert_equal 5, value
    end

    case result
    in BCDD::Context::Failure[_, _]
      raise
    in BCDD::Context::Success[:division_completed, {num: value}]
      assert_equal 5, value
    end
  end

  test '#deconstruct failure' do
    result = Divide.call(10, 0)

    assert_equal [:division_by_zero, { err: 'arg2 must not be zero' }], result.deconstruct

    case result
    in BCDD::Success[_, _]
      raise
    in BCDD::Failure[:division_by_zero, {err: msg}]
      assert_equal 'arg2 must not be zero', msg
    end

    case result
    in BCDD::Context::Success[_, _]
      raise
    in BCDD::Context::Failure[:division_by_zero, {err: msg}]
      assert_equal 'arg2 must not be zero', msg
    end
  end
end
