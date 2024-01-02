# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::Context::ExpectationsWithSourceFailureTypeTest < Minitest::Test
  class Divide
    include BCDD::Result::Context::Expectations.mixin(
      failure: :err
    )

    def call(arg1, arg2)
      validate_numbers(arg1, arg2)
        .and_then(:validate_non_zero)
        .and_then(:divide)
    end

    private

    def validate_numbers(arg1, arg2)
      arg1.is_a?(::Numeric) or return Failure(:err, message: 'arg1 must be numeric')
      arg2.is_a?(::Numeric) or return Failure(:err, message: 'arg2 must be numeric')

      Success(:ok, number1: arg1, number2: arg2)
    end

    def validate_non_zero(**input)
      return Success(:ok, **input) unless input[:number2].zero?

      Failure(:err, message: 'arg2 must not be zero')
    end

    def divide(number1:, number2:)
      Success(:ok, number: number1 / number2)
    end
  end

  test 'valid execution' do
    result = Divide.new.call(10, '2')

    assert result.failure?(:err)

    assert_predicate result, :failure?
  end

  test 'valid hooks' do
    increment = 0

    result = Divide.new.call(10, 0)

    result
      .on_success { increment += 1 }
      .on_failure { increment += 1 }
      .on_failure(:err) { increment += 1 }

    assert_equal 2, increment
  end

  test 'valid handlers' do
    increment = 0

    Divide.new.call(10, '5').handle do |on|
      on.success { increment += 1 }
      on.failure { increment += 1 }
      on.failure(:err) { increment += 1 }
    end

    Divide.new.call(10, 0).handle do |on|
      on.success { increment += 1 }
      on.success(:err) { increment += 1 }
      on.failure(:err) { increment += 1 }
      on.failure { increment += 1 }
    end

    assert_equal 2, increment
  end

  test 'invalid result type' do
    err = assert_raises(BCDD::Result::Contract::Error::UnexpectedType) do
      Divide.new.call(10, '2').failure?(:numbers)
    end

    assert_equal(
      'type :numbers is not allowed. Allowed types: :err',
      err.message
    )
  end

  test 'invalid hooks' do
    result = Divide.new.call(6, '2')

    err1 = assert_raises(BCDD::Result::Contract::Error::UnexpectedType) do
      result.on_failure(:bar) { :this_type_is_not_defined_in_the_expectations }
    end

    err2 = assert_raises(BCDD::Result::Contract::Error::UnexpectedType) do
      result.on_failure(:error) { :this_type_is_not_defined_in_the_expectations }
    end

    assert_equal(
      'type :bar is not allowed. Allowed types: :err',
      err1.message
    )

    assert_equal(
      'type :error is not allowed. Allowed types: :err',
      err2.message
    )
  end

  test 'invalid handlers' do
    result = Divide.new.call(6, '2')

    err1 = assert_raises(BCDD::Result::Contract::Error::UnexpectedType) do
      result.handle do |on|
        on.failure(:error) { :this_type_is_not_defined_in_the_expectations }
      end
    end

    err2 = assert_raises(BCDD::Result::Contract::Error::UnexpectedType) do
      result.handle do |on|
        on.failure(:bar) { :this_type_is_not_defined_in_the_expectations }
      end
    end

    assert_equal(
      'type :error is not allowed. Allowed types: :err',
      err1.message
    )

    assert_equal(
      'type :bar is not allowed. Allowed types: :err',
      err2.message
    )
  end

  test 'does not handle all cases' do
    err = assert_raises(BCDD::Result::Error::UnhandledTypes) do
      Divide.new.call(6, 2).handle do |on|
        on.success { :did_not_handle_all_expected_types }
      end
    end

    assert_equal(
      'You must handle all cases. This was not handled: :err',
      err.message
    )
  end
end
