# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::AndThenWithSubjectContinueInstanceTest < Minitest::Test
  class Divide
    include BCDD::Result.mixin(config: { addon: { continue: true } })

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
    success = Divide.new.call(10, 2)

    failure1 = Divide.new.call('10', 0)
    failure2 = Divide.new.call(10, '2')
    failure3 = Divide.new.call(10, 0)

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

  class FirstSuccessHaltsTheStepChainAndThenBlock
    include BCDD::Result.mixin(config: { addon: { continue: true } })

    def call
      Success(:first)
        .and_then { Continue(:second) }
        .and_then { Continue(:third) }
    end
  end

  class SecondSuccessHaltsTheStepChainAndThenBlock
    include BCDD::Result.mixin(config: { addon: { continue: true } })

    def call
      Continue(:first)
        .and_then { Success(:second) }
        .and_then { Continue(:third) }
    end
  end

  class ThirdSuccessHaltsTheStepChainAndThenBlock
    include BCDD::Result.mixin(config: { addon: { continue: true } })

    def call
      Continue(:first)
        .and_then { Continue(:second) }
        .and_then { Success(:third) }
    end
  end

  test 'the step chain halting (and_then block)' do
    result1 = FirstSuccessHaltsTheStepChainAndThenBlock.new.call
    result2 = SecondSuccessHaltsTheStepChainAndThenBlock.new.call
    result3 = ThirdSuccessHaltsTheStepChainAndThenBlock.new.call

    assert(result1.success?(:first) && result1.halted?)
    assert(result2.success?(:second) && result2.halted?)
    assert(result3.success?(:third) && result3.halted?)
  end

  class FirstSuccessHaltsTheStepChainAndThenMethod
    include BCDD::Result.mixin(config: { addon: { continue: true } })

    def call
      first_success
        .and_then(:second_success)
        .and_then(:third_success)
    end

    private

    def first_success;  Success(:first); end
    def second_success; Continue(:second); end
    def third_success;  Continue(:third); end
  end

  class SecondSuccessHaltsTheStepChainAndThenMethod
    include BCDD::Result.mixin(config: { addon: { continue: true } })

    def call
      first_success
        .and_then(:second_success)
        .and_then(:third_success)
    end

    private

    def first_success;  Continue(:first); end
    def second_success; Success(:second); end
    def third_success;  Continue(:third); end
  end

  class ThirdSuccessHaltsTheStepChainAndThenMethod
    include BCDD::Result.mixin(config: { addon: { continue: true } })

    def call
      first_success
        .and_then(:second_success)
        .and_then(:third_success)
    end

    private

    def first_success;  Continue(:first); end
    def second_success; Continue(:second); end
    def third_success;  Success(:third); end
  end

  test 'the step chain halting (and_then calling a method)' do
    result1 = FirstSuccessHaltsTheStepChainAndThenMethod.new.call
    result2 = SecondSuccessHaltsTheStepChainAndThenMethod.new.call
    result3 = ThirdSuccessHaltsTheStepChainAndThenMethod.new.call

    assert(result1.success?(:first) && result1.halted?)
    assert(result2.success?(:second) && result2.halted?)
    assert(result3.success?(:third) && result3.halted?)
  end
end
