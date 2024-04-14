# frozen_string_literal: true

require 'test_helper'

class Solid::Output::ExpectationsWithoutSourceSuccessInvalidTypesTest < Minitest::Test
  class Divide
    Result = Solid::Output::Expectations.new(
      success: %i[ok1 ok2 ok3]
    )

    def call(arg1, arg2)
      validate_numbers(arg1, arg2)
        .and_then { |input| validate_non_zero(**input) }
        .and_then { |input| divide(**input) }
    end

    private

    def validate_numbers(arg1, arg2)
      arg1.is_a?(::Numeric) or return Result::Failure(:err, message: 'arg1 must be numeric')
      arg2.is_a?(::Numeric) or return Result::Failure(:err, message: 'arg2 must be numeric')

      Result::Success(:ok1, number1: arg1, number2: arg2)
    end

    def validate_non_zero(**input)
      return Result::Success(:ok2, **input) unless input[:number2].zero?

      Result::Failure(:err, message: 'arg2 must not be zero')
    end

    def divide(number1:, number2:)
      Result::Success(:ok, number: number1 / number2)
    end
  end

  test 'unexpected type error' do
    err = assert_raises(Solid::Result::Contract::Error::UnexpectedType) do
      Divide.new.call(10, 2)
    end

    assert_equal(
      'type :ok is not allowed. Allowed types: :ok1, :ok2, :ok3',
      err.message
    )
  end
end
