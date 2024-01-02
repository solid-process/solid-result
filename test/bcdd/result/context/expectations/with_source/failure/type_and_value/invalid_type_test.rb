# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::Context::ExpectationsWithSourceFailureInvalidTypeAndValueTest < Minitest::Test
  class Divide
    include BCDD::Result::Context::Expectations.mixin(
      failure: {
        err1: ->(value) { value.is_a?(Hash) && value[:message].is_a?(String) },
        err2: ->(value) { value.is_a?(Hash) && value[:message].is_a?(String) }
      }
    )

    def call(arg1, arg2)
      validate_numbers(arg1, arg2)
        .and_then(:validate_non_zero)
        .and_then(:divide)
    end

    private

    def validate_numbers(arg1, arg2)
      arg1.is_a?(::Numeric) or return Failure(:err1, message: 'arg1 must be numeric')
      arg2.is_a?(::Numeric) or return Failure(:err, message: 'arg2 must be numeric')

      Success(:numbers, number1: arg1, number2: arg2)
    end

    def validate_non_zero(**input)
      return Success(:numbers, **input) unless input[:number2].zero?

      Failure(:err2, message: 'arg2 must not be zero')
    end

    def divide(number1:, number2:)
      Success(:division_completed, number: number1 / number2)
    end
  end

  test 'unexpected type error' do
    err = assert_raises(BCDD::Result::Contract::Error::UnexpectedType) do
      Divide.new.call(10, '2')
    end

    assert_equal(
      'type :err is not allowed. Allowed types: :err1, :err2',
      err.message
    )
  end
end
