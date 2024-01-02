# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::Context::ExpectationsWithSourceSuccessInvalidTypesTest < Minitest::Test
  class Divide
    include BCDD::Result::Context::Expectations.mixin(
      success: %i[ok1 ok2 ok3]
    )

    def call(arg1, arg2)
      validate_numbers(arg1, arg2)
        .and_then(:validate_non_zero)
        .and_then(:divide)
    end

    private

    def validate_numbers(arg1, arg2)
      arg1.is_a?(::Numeric) or return Failure(:invalid_arg, message: 'arg1 must be numeric')
      arg2.is_a?(::Numeric) or return Failure(:invalid_arg, message: 'arg2 must be numeric')

      Success(:ok1, number1: arg1, number2: arg2)
    end

    def validate_non_zero(**input)
      return Success(:ok2, **input) unless input[:number2].zero?

      Failure(:division_by_zero, message: 'arg2 must not be zero')
    end

    def divide(number1:, number2:)
      Success(:ok, number: number1 / number2)
    end
  end

  test 'unexpected type error' do
    err = assert_raises(BCDD::Result::Contract::Error::UnexpectedType) do
      Divide.new.call(10, 2)
    end

    assert_equal(
      'type :ok is not allowed. Allowed types: :ok1, :ok2, :ok3',
      err.message
    )
  end
end
