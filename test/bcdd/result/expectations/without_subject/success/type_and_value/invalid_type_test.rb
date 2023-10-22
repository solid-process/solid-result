# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::ExpectationsWithoutSubjectSuccessTypeAndValueInvalidTypeTest < Minitest::Test
  class Divide
    Result = BCDD::Result::Expectations.new(
      success: {
        division_completed: ->(value) { value.is_a?(Integer) || value.is_a?(Float) }
      }
    )

    def call(arg1, arg2)
      arg1.is_a?(::Numeric) or return Result::Failure(:invalid_arg, 'arg1 must be numeric')
      arg2.is_a?(::Numeric) or return Result::Failure(:invalid_arg, 'arg2 must be numeric')

      return Result::Failure(:division_by_zero, 'arg2 must not be zero') if arg2.zero?

      Result::Success(:ok, arg1 / arg2)
    end
  end

  test 'unexpected type error' do
    err = assert_raises(BCDD::Result::Expectations::Error::UnexpectedType) do
      Divide.new.call(10, 2)
    end

    assert_equal(
      'type :ok is not allowed. Allowed types: :division_completed',
      err.message
    )
  end
end
