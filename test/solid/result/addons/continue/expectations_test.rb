# frozen_string_literal: true

require 'test_helper'

class Solid::Result::AddonsContinueExpectationsTest < Minitest::Test
  class DivideType
    include Solid::Result::Expectations.mixin(
      config: { addon: { continue: true } },
      success: :ok,
      failure: :err
    )

    def call(arg1, arg2)
      validate_numbers(arg1, arg2)
        .and_then(:validate_non_zero)
        .and_then(:divide)
    end

    private

    def validate_numbers(arg1, arg2)
      arg1.is_a?(::Numeric) or return Failure(:err, 'arg1 must be numeric')
      arg2.is_a?(::Numeric) or return Failure(:err, 'arg2 must be numeric')

      Continue([arg1, arg2])
    end

    def validate_non_zero(numbers)
      return Continue(numbers) unless numbers.last.zero?

      Failure(:err, 'arg2 must not be zero')
    end

    def divide((number1, number2))
      Success(:ok, number1 / number2)
    end
  end

  class DivideTypes
    include Solid::Result::Expectations.mixin(
      config: { addon: { continue: true } },
      success: :division_completed,
      failure: %i[invalid_arg division_by_zero]
    )

    def call(arg1, arg2)
      validate_numbers(arg1, arg2)
        .and_then(:validate_non_zero)
        .and_then(:divide)
    end

    private

    def validate_numbers(arg1, arg2)
      arg1.is_a?(::Numeric) or return Failure(:invalid_arg, 'arg1 must be numeric')
      arg2.is_a?(::Numeric) or return Failure(:invalid_arg, 'arg2 must be numeric')

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

  module DivideTypeAndValue
    extend self, Solid::Result::Expectations.mixin(
      config: { addon: { continue: true } },
      success: { division_completed: Numeric },
      failure: { invalid_arg: String, division_by_zero: String }
    )

    def call(arg1, arg2)
      validate_numbers(arg1, arg2)
        .and_then(:validate_non_zero)
        .and_then(:divide)
    end

    private

    def validate_numbers(arg1, arg2)
      arg1.is_a?(::Numeric) or return Failure(:invalid_arg, 'arg1 must be numeric')
      arg2.is_a?(::Numeric) or return Failure(:invalid_arg, 'arg2 must be numeric')

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
    result1 = DivideType.new.call(10, 2)
    result2 = DivideTypes.new.call(10, 2)
    result3 = DivideTypeAndValue.call(10, 2)

    assert result1.success?(:ok)
    assert result2.success?(:division_completed)
    assert result3.success?(:division_completed)
  end

  test 'type checking' do
    success1 = DivideType.new.call(10, 2)
    success2 = DivideTypes.new.call(10, 2)
    success3 = DivideTypeAndValue.call(10, 2)

    failure1 = DivideType.new.call('10', 0)
    failure2 = DivideTypes.new.call('10', 0)
    failure3 = DivideTypeAndValue.call('10', 0)

    assert_raises(Solid::Result::Contract::Error::UnexpectedType) { success1.success?(:division_completed) }
    assert_raises(Solid::Result::Contract::Error::UnexpectedType) { success2.success?(:ok) }
    assert_raises(Solid::Result::Contract::Error::UnexpectedType) { success3.success?(:ok) }

    assert_raises(Solid::Result::Contract::Error::UnexpectedType) { failure1.failure?(:invalid_arg) }
    assert_raises(Solid::Result::Contract::Error::UnexpectedType) { failure2.failure?(:err) }
    assert_raises(Solid::Result::Contract::Error::UnexpectedType) { failure3.failure?(:err) }
  end

  class InstanceFirstSuccessToTerminateTheStepChainAndThenBlock
    include Solid::Result::Expectations.mixin(
      config: { addon: { continue: true } },
      success: :first
    )

    def call
      Success(:first)
        .and_then { Continue(:second) }
        .and_then { Continue(:third) }
    end
  end

  class InstanceSecondSuccessToTerminateTheStepChainAndThenBlock
    include Solid::Result::Expectations.mixin(
      config: { addon: { continue: true } },
      success: :second
    )

    def call
      Continue(:first)
        .and_then { Success(:second) }
        .and_then { Continue(:third) }
    end
  end

  class InstanceThirdSuccessToTerminateTheStepChainAndThenBlock
    include Solid::Result::Expectations.mixin(
      config: { addon: { continue: true } },
      success: :third
    )

    def call
      Continue(:first)
        .and_then { Continue(:second) }
        .and_then { Success(:third) }
    end
  end

  module SingletonFirstSuccessToTerminateTheStepChainAndThenBlock
    extend self, Solid::Result::Expectations.mixin(
      config: { addon: { continue: true } },
      success: :first
    )

    def call
      Success(:first)
        .and_then { Continue(:second) }
        .and_then { Continue(:third) }
    end
  end

  module SingletonSecondSuccessToTerminateTheStepChainAndThenBlock
    extend self, Solid::Result::Expectations.mixin(
      config: { addon: { continue: true } },
      success: :second
    )

    def call
      Continue(:first)
        .and_then { Success(:second) }
        .and_then { Continue(:third) }
    end
  end

  module SingletonThirdSuccessToTerminateTheStepChainAndThenBlock
    extend self, Solid::Result::Expectations.mixin(
      config: { addon: { continue: true } },
      success: :third
    )

    def call
      Continue(:first)
        .and_then { Continue(:second) }
        .and_then { Success(:third) }
    end
  end

  test 'the step chain termination (and_then block)' do
    instance_result1 = InstanceFirstSuccessToTerminateTheStepChainAndThenBlock.new.call
    instance_result2 = InstanceSecondSuccessToTerminateTheStepChainAndThenBlock.new.call
    instance_result3 = InstanceThirdSuccessToTerminateTheStepChainAndThenBlock.new.call

    singleton_result1 = SingletonFirstSuccessToTerminateTheStepChainAndThenBlock.call
    singleton_result2 = SingletonSecondSuccessToTerminateTheStepChainAndThenBlock.call
    singleton_result3 = SingletonThirdSuccessToTerminateTheStepChainAndThenBlock.call

    assert(instance_result1.success?(:first) && instance_result1.terminal?)
    assert(instance_result2.success?(:second) && instance_result2.terminal?)
    assert(instance_result3.success?(:third) && instance_result3.terminal?)

    assert(singleton_result1.success?(:first) && singleton_result1.terminal?)
    assert(singleton_result2.success?(:second) && singleton_result2.terminal?)
    assert(singleton_result3.success?(:third) && singleton_result3.terminal?)
  end

  class InstanceFirstSuccessToTerminateTheStepChainAndThenMethod
    include Solid::Result::Expectations.mixin(
      config: { addon: { continue: true } },
      success: :first
    )

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

  class InstanceSecondSuccessToTerminateTheStepChainAndThenMethod
    include Solid::Result::Expectations.mixin(
      config: { addon: { continue: true } },
      success: :second
    )

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

  class InstanceThirdSuccessToTerminateTheStepChainAndThenMethod
    include Solid::Result::Expectations.mixin(
      config: { addon: { continue: true } },
      success: :third
    )

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

  module SingletonFirstSuccessToTerminateTheStepChainAndThenMethod
    extend self, Solid::Result::Expectations.mixin(
      config: { addon: { continue: true } },
      success: :first
    )

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

  module SingletonSecondSuccessToTerminateTheStepChainAndThenMethod
    extend self, Solid::Result::Expectations.mixin(
      config: { addon: { continue: true } },
      success: :second
    )

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

  module SingletonThirdSuccessToTerminateTheStepChainAndThenMethod
    extend self, Solid::Result::Expectations.mixin(
      config: { addon: { continue: true } },
      success: :third
    )

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

  test 'the step chain termination (and_then calling a method)' do
    instance_result1 = InstanceFirstSuccessToTerminateTheStepChainAndThenMethod.new.call
    instance_result2 = InstanceSecondSuccessToTerminateTheStepChainAndThenMethod.new.call
    instance_result3 = InstanceThirdSuccessToTerminateTheStepChainAndThenMethod.new.call

    assert(instance_result1.success?(:first) && instance_result1.terminal?)
    assert(instance_result2.success?(:second) && instance_result2.terminal?)
    assert(instance_result3.success?(:third) && instance_result3.terminal?)
  end
end
