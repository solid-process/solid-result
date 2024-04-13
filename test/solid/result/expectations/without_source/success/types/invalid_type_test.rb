# frozen_string_literal: true

require 'test_helper'

class Solid::Result::ExpectationsWithoutSourceSuccessInvalidTypesTest < Minitest::Test
  class Divide
    Result = Solid::Result::Expectations.new(
      success: %i[ok1 ok2 ok3]
    )

    def call(arg1, arg2)
      validate_numbers(arg1, arg2)
        .and_then { |numbers| validate_non_zero(numbers) }
        .and_then { |numbers| divide(numbers) }
    end

    private

    def validate_numbers(arg1, arg2)
      arg1.is_a?(::Numeric) or return Result::Failure(:invalid_arg, 'arg1 must be numeric')
      arg2.is_a?(::Numeric) or return Result::Failure(:invalid_arg, 'arg2 must be numeric')

      Result::Success(:ok1, [arg1, arg2])
    end

    def validate_non_zero(numbers)
      return Result::Success(:ok2, numbers) unless numbers.last.zero?

      Result::Failure(:division_by_zero, 'arg2 must not be zero')
    end

    def divide((number1, number2))
      Result::Success(:ok, number1 / number2)
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
