# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::ExpectationsWithoutSourceFailureInvalidTypeTest < Minitest::Test
  class Divide
    Result = BCDD::Result::Expectations.new(
      failure: :err
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

      Result::Failure(:err2, 'arg2 must not be zero')
    end

    def divide((number1, number2))
      Result::Success(:ok, number1 / number2)
    end
  end

  test 'unexpected type error' do
    err = assert_raises(BCDD::Result::Contract::Error::UnexpectedType) do
      Divide.new.call('10', 2)
    end

    assert_equal(
      'type :err1 is not allowed. Allowed types: :err',
      err.message
    )
  end
end
