# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::Context::ExpectationsWithoutSubjectFailureInvalidTypesTest < Minitest::Test
  class Divide
    Result = BCDD::Result::Context::Expectations.new(
      failure: %i[err1 err2]
    )

    def call(arg1, arg2)
      validate_numbers(arg1, arg2)
        .and_then { |input| validate_non_zero(**input) }
        .and_then { |input| divide(**input) }
    end

    private

    def validate_numbers(arg1, arg2)
      arg1.is_a?(::Numeric) or return Result::Failure(:err1, message: 'arg1 must be numeric')
      arg2.is_a?(::Numeric) or return Result::Failure(:err, message: 'arg2 must be numeric')

      Result::Success(:ok, number1: arg1, number2: arg2)
    end

    def validate_non_zero(number2:, **input)
      return Result::Success(:ok, number2: number2, **input) unless number2.zero?

      Failure(:err2, message: 'arg2 must not be zero')
    end

    def divide(number1:, number2:)
      Result::Success(:ok, number: number1 / number2)
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
