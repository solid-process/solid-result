# frozen_string_literal: true

require 'test_helper'

class Solid::Output::PatternMatchingDeconstructKeysTest < Minitest::Test
  Divide = ->(arg1, arg2) do
    arg1.is_a?(::Numeric) or return Solid::Output::Failure(:invalid_arg, err: 'arg1 must be numeric')
    arg2.is_a?(::Numeric) or return Solid::Output::Failure(:invalid_arg, err: 'arg2 must be numeric')

    return Solid::Output::Failure(:division_by_zero, err: 'arg2 must not be zero') if arg2.zero?

    Solid::Output::Success(:division_completed, num: arg1 / arg2)
  end

  test '#deconstruct_keys success' do
    result = Divide.call(10, 2)

    assert_equal({ num: 5 }, result.deconstruct_keys([]))

    case result
    in Solid::Failure(type: _, value: _)
      raise
    in Solid::Success(type: :division_completed, value: { num: num })
      assert_equal 5, num
    end

    case result
    in Solid::Failure
      raise
    in Solid::Success(num: num)
      assert_equal 5, num
    end

    case result
    in Solid::Output::Failure(type: _, value: _)
      raise
    in Solid::Output::Success(type: :division_completed, value: { num: num })
      assert_equal 5, num
    end

    case result
    in Solid::Output::Failure
      raise
    in Solid::Output::Success(num: num)
      assert_equal 5, num
    end
  end

  test '#deconstruct_keys failure' do
    result = Divide.call(10, 0)

    assert_equal({ err: 'arg2 must not be zero' }, result.deconstruct_keys([]))

    case result
    in Solid::Success(type: _, value: _)
      raise
    in Solid::Failure(type: :division_by_zero, value: {err: msg})
      assert_equal 'arg2 must not be zero', msg
    end

    case result
    in Solid::Success
      raise
    in Solid::Failure(err: msg)
      assert_equal 'arg2 must not be zero', msg
    end

    case result
    in Solid::Output::Success(type: _, value: _)
      raise
    in Solid::Output::Failure(type: :division_by_zero, value: {err: msg})
      assert_equal 'arg2 must not be zero', msg
    end

    case result
    in Solid::Output::Success
      raise
    in Solid::Output::Failure(err: msg)
      assert_equal 'arg2 must not be zero', msg
    end
  end
end
