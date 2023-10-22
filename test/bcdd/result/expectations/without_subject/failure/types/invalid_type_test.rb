# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::ExpectationsWithoutSubjectFailureInvalidTypesTest < Minitest::Test
  class Divide
    Result = BCDD::Result::Expectations.new(
      failure: %i[err1 err2]
    )

    def call(arg1, arg2)
      validate_numbers(arg1, arg2)
        .and_then { |numbers| validate_non_zero(numbers) }
        .and_then { |numbers| divide(numbers) }
    end

    private

    def validate_numbers(arg1, arg2)
      arg1.is_a?(::Numeric) or return Result::Failure(:err1, 'arg1 must be numeric')
      arg2.is_a?(::Numeric) or return Result::Failure(:err, 'arg2 must be numeric')

      Result::Success(:ok, [arg1, arg2])
    end

    def validate_non_zero(numbers)
      return Result::Success(:ok, numbers) unless numbers.last.zero?

      Failure(:err2, 'arg2 must not be zero')
    end

    def divide((number1, number2))
      Result::Success(:ok, number1 / number2)
    end
  end

  test 'unexpected type error' do
    err = assert_raises(BCDD::Result::Expectations::Error::UnexpectedType) do
      Divide.new.call(10, '2')
    end

    assert_equal(
      'type :err is not allowed. Allowed types: :err1, :err2',
      err.message
    )
  end
end
