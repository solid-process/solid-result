# frozen_string_literal: true

require 'test_helper'

class BCDD::Context::AddonsGivenSingletonTest < Minitest::Test
  module Divide
    extend self, BCDD::Context.mixin(config: { addon: { continue: true } })

    def call(arg1, arg2)
      Given(number1: arg1, number2: arg2)
        .and_then(:validate_numbers)
        .and_then(:validate_non_zero)
        .and_then(:divide, extra_division: 2)
    end

    private

    def validate_numbers(number1:, number2:)
      number1.is_a?(Numeric) or return Failure(:invalid_arg, message: 'arg1 must be numeric')
      number2.is_a?(Numeric) or return Failure(:invalid_arg, message: 'arg2 must be numeric')

      Continue()
    end

    def validate_non_zero(number2:, **)
      return Continue() unless number2.zero?

      Failure(:division_by_zero, message: 'arg2 must not be zero')
    end

    def divide(number1:, number2:, extra_division:)
      Success(:division_completed, number: (number1 / number2) / extra_division)
    end
  end

  test 'method chaining' do
    success = Divide.call(20, 2)

    failure1 = Divide.call('10', 0)
    failure2 = Divide.call(10, '2')
    failure3 = Divide.call(10, 0)

    assert_predicate success, :success?
    assert_equal :division_completed, success.type
    assert_equal({ number: 5 }, success.value)

    assert_predicate failure1, :failure?
    assert_equal :invalid_arg, failure1.type
    assert_equal({ message: 'arg1 must be numeric' }, failure1.value)

    assert_predicate failure2, :failure?
    assert_equal :invalid_arg, failure2.type
    assert_equal({ message: 'arg2 must be numeric' }, failure2.value)

    assert_predicate failure3, :failure?
    assert_equal :division_by_zero, failure3.type
    assert_equal({ message: 'arg2 must not be zero' }, failure3.value)
  end
end
