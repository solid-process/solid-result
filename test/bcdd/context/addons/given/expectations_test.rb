# frozen_string_literal: true

require 'test_helper'

class BCDD::Context::AddonsGivenExpectationsTest < Minitest::Test
  class DivideType
    include BCDD::Context::Expectations.mixin(
      config: { addon: { continue: true } },
      success: :ok,
      failure: :err
    )

    def call(arg1, arg2)
      Given(number1: arg1, number2: arg2)
        .and_then(:validate_numbers)
        .and_then(:validate_non_zero)
        .and_then(:divide)
    end

    private

    def validate_numbers(number1:, number2:)
      number1.is_a?(::Numeric) or return Failure(:err, message: 'arg1 must be numeric')
      number2.is_a?(::Numeric) or return Failure(:err, message: 'arg2 must be numeric')

      Continue()
    end

    def validate_non_zero(number2:, **)
      number2.zero? ? Failure(:err, 'arg2 must not be zero') : Continue()
    end

    def divide(number1:, number2:)
      Success(:ok, number: number1 / number2)
    end
  end

  class DivideTypes
    include BCDD::Context::Expectations.mixin(
      config: { addon: { continue: true } },
      success: :division_completed,
      failure: %i[invalid_arg division_by_zero]
    )

    def call(arg1, arg2)
      Given(number1: arg1, number2: arg2)
        .and_then(:validate_numbers)
        .and_then(:validate_non_zero)
        .and_then(:divide)
    end

    private

    def validate_numbers(number1:, number2:)
      number1.is_a?(::Numeric) or return Failure(:invalid_arg, message: 'arg1 must be numeric')
      number2.is_a?(::Numeric) or return Failure(:invalid_arg, message: 'arg2 must be numeric')

      Continue()
    end

    def validate_non_zero(number2:, **)
      number2.zero? ? Failure(:err, message: 'arg2 must not be zero') : Continue()
    end

    def divide(number1:, number2:)
      Success(:division_completed, number: number1 / number2)
    end
  end

  module DivideTypeAndValue
    extend self, BCDD::Context::Expectations.mixin(
      config: { addon: { continue: true } },
      success: {
        division_completed: ->(value) {
          case value
          in { number: Numeric } then true
          end
        }
      },
      failure: {
        invalid_arg: ->(value) {
          case value
          in { message: String } then true
          end
        },
        division_by_zero: ->(value) {
          case value
          in { message: String } then true
          end
        }
      }
    )

    def call(arg1, arg2)
      Given(number1: arg1, number2: arg2)
        .and_then(:validate_numbers)
        .and_then(:validate_non_zero)
        .and_then(:divide)
    end

    private

    def validate_numbers(number1:, number2:)
      number1.is_a?(::Numeric) or return Failure(:invalid_arg, message: 'arg1 must be numeric')
      number2.is_a?(::Numeric) or return Failure(:invalid_arg, message: 'arg2 must be numeric')

      Continue()
    end

    def validate_non_zero(number2:, **)
      return Failure(:division_by_zero, message: 'arg2 must not be zero') if number2.zero?

      Continue()
    end

    def divide(number1:, number2:)
      Success(:division_completed, number: number1 / number2)
    end
  end

  test 'method chaining' do
    result1 = DivideType.new.call(10, 2)
    result2 = DivideTypes.new.call(10, 2)
    result3 = DivideTypeAndValue.call(10, 2)

    assert result1.success?(:ok)
    assert result2.success?(:division_completed)
    assert result3.success?(:division_completed)
  end
end
