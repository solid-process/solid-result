# frozen_string_literal: true

require 'test_helper'

class Solid::Result::PatternMatchingDeconstructKeysTest < Minitest::Test
  Divide = ->(arg1, arg2) do
    arg1.is_a?(::Numeric) or return Solid::Result::Failure(:invalid_arg, 'arg1 must be numeric')
    arg2.is_a?(::Numeric) or return Solid::Result::Failure(:invalid_arg, 'arg2 must be numeric')

    return Solid::Result::Failure(:division_by_zero, 'arg2 must not be zero') if arg2.zero?

    Solid::Result::Success(:division_completed, arg1 / arg2)
  end

  test '#deconstruct_keys success' do
    result = Divide.call(10, 2)

    assert_equal(5, result.deconstruct_keys([]))

    case result
    in Solid::Failure(type: _, value: _)
      raise
    in Solid::Success(type: :division_completed, value: value)
      assert_equal 5, value
    end

    case result
    in Solid::Result::Failure(type: _, value: _)
      raise
    in Solid::Result::Success(type: :division_completed, value: value)
      assert_equal 5, value
    end
  end

  test '#deconstruct_keys failure' do
    result = Divide.call(10, 0)

    assert_equal('arg2 must not be zero', result.deconstruct_keys([]))

    case result
    in Solid::Success(type: _, value: _)
      raise
    in Solid::Failure(type: :division_by_zero, value: msg)
      assert_equal 'arg2 must not be zero', msg
    end

    case result
    in Solid::Result::Success(type: _, value: _)
      raise
    in Solid::Result::Failure(type: :division_by_zero, value: msg)
      assert_equal 'arg2 must not be zero', msg
    end
  end
end
