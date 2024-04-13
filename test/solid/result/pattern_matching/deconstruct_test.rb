# frozen_string_literal: true

require 'test_helper'

class Solid::Result::PatternMatchingDeconstructTest < Minitest::Test
  Divide = ->(arg1, arg2) do
    arg1.is_a?(::Numeric) or return Solid::Result::Failure(:invalid_arg, 'arg1 must be numeric')
    arg2.is_a?(::Numeric) or return Solid::Result::Failure(:invalid_arg, 'arg2 must be numeric')

    return Solid::Result::Failure(:division_by_zero, 'arg2 must not be zero') if arg2.zero?

    Solid::Result::Success(:division_completed, arg1 / arg2)
  end

  test '#deconstruct success' do
    result = Divide.call(10, 2)

    assert_equal [:division_completed, 5], result.deconstruct

    case result
    in Solid::Failure[_, _]
      raise
    in Solid::Success[:division_completed, value]
      assert_equal 5, value
    end

    case result
    in Solid::Result::Failure[_, _]
      raise
    in Solid::Result::Success[:division_completed, value]
      assert_equal 5, value
    end
  end

  test '#deconstruct failure' do
    result = Divide.call(10, 0)

    assert_equal [:division_by_zero, 'arg2 must not be zero'], result.deconstruct

    case result
    in Solid::Success[_, _]
      raise
    in Solid::Failure[:division_by_zero, msg]
      assert_equal 'arg2 must not be zero', msg
    end

    case result
    in Solid::Result::Success[_, _]
      raise
    in Solid::Result::Failure[:division_by_zero, msg]
      assert_equal 'arg2 must not be zero', msg
    end
  end
end
