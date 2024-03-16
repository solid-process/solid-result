# frozen_string_literal: true

require 'test_helper'

class BCDD::Context::AddonsContinueSingletonTest < Minitest::Test
  module Divide
    extend self, BCDD::Context.mixin(config: { addon: { continue: true } })

    def call(arg1, arg2)
      validate_numbers(arg1, arg2)
        .and_then(:validate_non_zero)
        .and_then(:divide, extra_division: 2)
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

    def divide(number1:, number2:, extra_division:)
      Success(:division_completed, number: (number1 / number2) / extra_division)
    end
  end

  test 'method chaining using Continue' do
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

  module FirstSuccessToTerminateTheStepChainAndThenBlock
    extend self, BCDD::Context.mixin(config: { addon: { continue: true } })

    def call
      Success(:first)
        .and_then { Continue(second: true) }
        .and_then { Continue(third: true) }
    end
  end

  module SecondSuccessToTerminateTheStepChainAndThenBlock
    extend self, BCDD::Context.mixin(config: { addon: { continue: true } })

    def call
      Continue(first: true)
        .and_then { Success(:second) }
        .and_then { Continue(third: true) }
    end
  end

  module ThirdSuccessToTerminateTheStepChainAndThenBlock
    extend self, BCDD::Context.mixin(config: { addon: { continue: true } })

    def call
      Continue(first: true)
        .and_then { Continue(second: true) }
        .and_then { Success(:third) }
    end
  end

  test 'the step chain termination (and_then block)' do
    result1 = FirstSuccessToTerminateTheStepChainAndThenBlock.call
    result2 = SecondSuccessToTerminateTheStepChainAndThenBlock.call
    result3 = ThirdSuccessToTerminateTheStepChainAndThenBlock.call

    assert(result1.success?(:first) && result1.terminal?)
    assert(result2.success?(:second) && result2.terminal?)
    assert(result3.success?(:third) && result3.terminal?)
  end

  module FirstSuccessToTerminateTheStepChainAndThenMethod
    extend self, BCDD::Context.mixin(config: { addon: { continue: true } })

    def call
      first_success
        .and_then(:second_success)
        .and_then(:third_success)
    end

    private

    def first_success;  Success(:first); end
    def second_success; Continue(second: true); end
    def third_success;  Continue(third: true); end
  end

  module SecondSuccessToTerminateTheStepChainAndThenMethod
    extend self, BCDD::Context.mixin(config: { addon: { continue: true } })

    def call
      first_success
        .and_then(:second_success)
        .and_then(:third_success)
    end

    private

    def first_success;  Continue(first: true); end
    def second_success; Success(:second); end
    def third_success;  Continue(third: true); end
  end

  module ThirdSuccessToTerminateTheStepChainAndThenMethod
    extend self, BCDD::Context.mixin(config: { addon: { continue: true } })

    def call
      first_success
        .and_then(:second_success)
        .and_then(:third_success)
    end

    private

    def first_success;  Continue(first: true); end
    def second_success; Continue(second: true); end
    def third_success;  Success(:third); end
  end

  test 'the step chain termination (and_then calling a method)' do
    result1 = FirstSuccessToTerminateTheStepChainAndThenMethod.call
    result2 = SecondSuccessToTerminateTheStepChainAndThenMethod.call
    result3 = ThirdSuccessToTerminateTheStepChainAndThenMethod.call

    assert(result1.success?(:first) && result1.terminal?)
    assert(result2.success?(:second) && result2.terminal?)
    assert(result3.success?(:third) && result3.terminal?)
  end
end
