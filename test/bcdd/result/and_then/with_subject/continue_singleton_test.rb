# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::AndThenWithSubjectContinueSingletonTest < Minitest::Test
  module Divide
    extend self, BCDD::Result.mixin(with: :Continue)

    def call(arg1, arg2)
      validate_numbers(arg1, arg2)
        .and_then(:validate_non_zero)
        .and_then(:divide)
    end

    private

    def validate_numbers(arg1, arg2)
      arg1.is_a?(Numeric) or return Failure(:invalid_arg, 'arg1 must be numeric')
      arg2.is_a?(Numeric) or return Failure(:invalid_arg, 'arg2 must be numeric')

      Continue([arg1, arg2])
    end

    def validate_non_zero(numbers)
      return Continue(numbers) unless numbers.last.zero?

      Failure(:division_by_zero, 'arg2 must not be zero')
    end

    def divide((number1, number2))
      Success(:division_completed, number1 / number2)
    end
  end

  test 'method chaining using Continue' do
    success = Divide.call(10, 2)

    failure1 = Divide.call('10', 0)
    failure2 = Divide.call(10, '2')
    failure3 = Divide.call(10, 0)

    assert_predicate success, :success?
    assert_equal :division_completed, success.type
    assert_equal 5, success.value

    assert_predicate failure1, :failure?
    assert_equal :invalid_arg, failure1.type
    assert_equal 'arg1 must be numeric', failure1.value

    assert_predicate failure2, :failure?
    assert_equal :invalid_arg, failure2.type
    assert_equal 'arg2 must be numeric', failure2.value

    assert_predicate failure3, :failure?
    assert_equal :division_by_zero, failure3.type
    assert_equal 'arg2 must not be zero', failure3.value
  end
end

class BCDD::Result::AndThenWithSubjectContinueFollowedBySuccessResultsSingletonTest < Minitest::Test
  module ContinuedFollowedBySuccessResults
    extend self, BCDD::Result.mixin(with: :Continue)

    def call
      Continue(0)
        .and_then { Success(:first_success, 1) }
        .and_then { Success(:second_success, 2) }
    end
  end

  test 'method chain interupts after the first Success' do
    success = ContinuedFollowedBySuccessResults.call

    assert_predicate success, :success?
    assert_equal :first_success, success.type
    assert_equal 1, success.value
  end
end
