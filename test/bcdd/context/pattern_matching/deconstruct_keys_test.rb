# frozen_string_literal: true

require 'test_helper'

class BCDD::Context::PatternMatchingDeconstructKeysTest < Minitest::Test
  Divide = ->(arg1, arg2) do
    arg1.is_a?(::Numeric) or return BCDD::Context::Failure(:invalid_arg, err: 'arg1 must be numeric')
    arg2.is_a?(::Numeric) or return BCDD::Context::Failure(:invalid_arg, err: 'arg2 must be numeric')

    return BCDD::Context::Failure(:division_by_zero, err: 'arg2 must not be zero') if arg2.zero?

    BCDD::Context::Success(:division_completed, num: arg1 / arg2)
  end

  test '#deconstruct_keys success' do
    result = Divide.call(10, 2)

    assert_equal({ num: 5 }, result.deconstruct_keys([]))

    case result
    in BCDD::Failure(type: _, value: _)
      raise
    in BCDD::Success(type: :division_completed, value: { num: num })
      assert_equal 5, num
    end

    case result
    in BCDD::Failure
      raise
    in BCDD::Success(num: num)
      assert_equal 5, num
    end

    case result
    in BCDD::Context::Failure(type: _, value: _)
      raise
    in BCDD::Context::Success(type: :division_completed, value: { num: num })
      assert_equal 5, num
    end

    case result
    in BCDD::Context::Failure
      raise
    in BCDD::Context::Success(num: num)
      assert_equal 5, num
    end
  end

  test '#deconstruct_keys failure' do
    result = Divide.call(10, 0)

    assert_equal({ err: 'arg2 must not be zero' }, result.deconstruct_keys([]))

    case result
    in BCDD::Success(type: _, value: _)
      raise
    in BCDD::Failure(type: :division_by_zero, value: {err: msg})
      assert_equal 'arg2 must not be zero', msg
    end

    case result
    in BCDD::Success
      raise
    in BCDD::Failure(err: msg)
      assert_equal 'arg2 must not be zero', msg
    end

    case result
    in BCDD::Context::Success(type: _, value: _)
      raise
    in BCDD::Context::Failure(type: :division_by_zero, value: {err: msg})
      assert_equal 'arg2 must not be zero', msg
    end

    case result
    in BCDD::Context::Success
      raise
    in BCDD::Context::Failure(err: msg)
      assert_equal 'arg2 must not be zero', msg
    end
  end
end
