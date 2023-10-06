# frozen_string_literal: true

require 'test_helper'

class BCDD::PatternMatchingDeconstructKeysTest < Minitest::Test
  Divide = ->(arg1, arg2) do
    arg1.is_a?(::Numeric) or return BCDD::Result::Failure(:invalid_arg, 'arg1 must be numeric')
    arg2.is_a?(::Numeric) or return BCDD::Result::Failure(:invalid_arg, 'arg2 must be numeric')

    return BCDD::Result::Failure(:division_by_zero, 'arg2 must not be zero') if arg2.zero?

    BCDD::Result::Success(:division_completed, arg1 / arg2)
  end

  test '#deconstruct_keys success' do
    result = Divide.call(10, 2)

    assert_equal({ success: { division_completed: 5 } }, result.deconstruct_keys([]))

    case result
    in { failure: _ }
      raise
    in { success: { division_completed: value } }
      assert_equal 5, value
    end
  end

  test '#deconstruct_keys failure' do
    result = Divide.call(10, 0)

    assert_equal(
      { failure: { division_by_zero: 'arg2 must not be zero' } },
      result.deconstruct_keys([])
    )

    case result
    in { success: _ }
      raise
    in { failure: { division_by_zero: msg } }
      assert_equal 'arg2 must not be zero', msg
    end
  end
end
