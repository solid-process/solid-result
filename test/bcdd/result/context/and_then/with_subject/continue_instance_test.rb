# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::Context::AndThenWithSubjectContinueInstanceTest < Minitest::Test
  class Divide
    include BCDD::Result::Context.mixin(config: :continue)

    def call(arg1, arg2)
      validate_numbers(arg1, arg2)
        .and_then(:validate_non_zero)
        .and_then(:divide)
    end

    private

    def validate_numbers(arg1, arg2)
      arg1.is_a?(Numeric) or return Failure(:invalid_arg, message: 'arg1 must be numeric')
      arg2.is_a?(Numeric) or return Failure(:invalid_arg, message: 'arg2 must be numeric')

      Continue(number1: arg1, number2: arg2)
    end

    def validate_non_zero(number2:, **)
      return Continue() unless number2.zero?

      Failure(:division_by_zero, message: 'arg2 must not be zero')
    end

    def divide(number1:, number2:)
      Success(:division_completed, number: number1 / number2)
    end
  end

  test 'method chaining using Continue' do
    success = Divide.new.call(10, 2)

    failure1 = Divide.new.call('10', 0)
    failure2 = Divide.new.call(10, '2')
    failure3 = Divide.new.call(10, 0)

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
