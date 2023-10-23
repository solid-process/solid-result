# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::ExpectationsWithSubjectFailureInvalidTypeTest < Minitest::Test
  class Divide
    include BCDD::Result::Expectations.mixin(
      failure: :err
    )

    def call(arg1, arg2)
      validate_numbers(arg1, arg2)
        .and_then(:validate_non_zero)
        .and_then(:divide)
    end

    private

    def validate_numbers(arg1, arg2)
      arg1.is_a?(::Numeric) or return Failure(:err1, 'arg1 must be numeric')
      arg2.is_a?(::Numeric) or return Failure(:err, 'arg2 must be numeric')

      Success(:ok, [arg1, arg2])
    end

    def validate_non_zero(numbers)
      return Success(:ok, numbers) unless numbers.last.zero?

      Failure(:err2, 'arg2 must not be zero')
    end

    def divide((number1, number2))
      Success(:ok, number1 / number2)
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
