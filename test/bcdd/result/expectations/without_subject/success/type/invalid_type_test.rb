# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::ExpectationsWithoutSubjectSuccessInvalidTypeTest < Minitest::Test
  class Divide
    Expected = BCDD::Result::Expectations.new(
      success: :ok
    )

    def call(arg1, arg2)
      arg1.is_a?(::Numeric) or return Expected::Failure(:invalid_arg, 'arg1 must be numeric')
      arg2.is_a?(::Numeric) or return Expected::Failure(:invalid_arg, 'arg2 must be numeric')

      return Expected::Failure(:division_by_zero, 'arg2 must not be zero') if arg2.zero?

      Expected::Success(:division_completed, arg1 / arg2)
    end
  end

  test 'unexpected type error' do
    err = assert_raises(BCDD::Result::Expectations::Error::UnexpectedType) do
      Divide.new.call(10, 2)
    end

    assert_equal(
      'type :division_completed is not allowed. Allowed types: :ok',
      err.message
    )
  end
end
