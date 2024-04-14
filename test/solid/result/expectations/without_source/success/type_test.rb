# frozen_string_literal: true

require 'test_helper'

class Solid::Result::ExpectationsWithoutSourceSuccessTypeTest < Minitest::Test
  class Divide
    Result = Solid::Result::Expectations.new(
      success: :ok
    )

    def call(arg1, arg2)
      validate_numbers(arg1, arg2)
        .and_then { |numbers| validate_non_zero(numbers) }
        .and_then { |numbers| divide(numbers) }
    end

    private

    def validate_numbers(arg1, arg2)
      arg1.is_a?(::Numeric) or return Result::Failure(:invalid_arg, 'arg1 must be numeric')
      arg2.is_a?(::Numeric) or return Result::Failure(:invalid_arg, 'arg2 must be numeric')

      Result::Success(:ok, [arg1, arg2])
    end

    def validate_non_zero(numbers)
      return Result::Success(:ok, numbers) unless numbers.last.zero?

      Result::Failure(:division_by_zero, 'arg2 must not be zero')
    end

    def divide((number1, number2))
      Result::Success(:ok, number1 / number2)
    end
  end

  test 'valid execution' do
    result = Divide.new.call(10, 2)

    assert result.success?(:ok)

    assert_predicate result, :success?
  end

  test 'valid hooks' do
    increment = 0

    result = Divide.new.call(10, 5)

    result
      .on_failure { increment += 1 }
      .on_success { increment += 1 }
      .on_success(:ok) { increment += 1 }

    assert_equal 2, increment
  end

  test 'valid handlers' do
    increment = 0

    Divide.new.call(10, 5).handle do |on|
      on.failure { increment += 1 }
      on.success { increment += 1 }
      on.success(:ok) { increment += 1 }
    end

    Divide.new.call(10, 5).handle do |on|
      on.failure { increment += 1 }
      on.success(:ok) { increment += 1 }
      on.success { increment += 1 }
    end

    assert_equal 2, increment
  end

  test 'invalid result type' do
    err = assert_raises(Solid::Result::Contract::Error::UnexpectedType) do
      Divide.new.call(10, 2).success?(:numbers)
    end

    assert_equal(
      'type :numbers is not allowed. Allowed types: :ok',
      err.message
    )
  end

  test 'invalid hooks' do
    result = Divide.new.call(6, 2)

    err1 = assert_raises(Solid::Result::Contract::Error::UnexpectedType) do
      result.on_success(:foo) { :this_type_is_not_defined_in_the_expectations }
    end

    err2 = assert_raises(Solid::Result::Contract::Error::UnexpectedType) do
      result.on_success(:bar) { :this_type_is_not_defined_in_the_expectations }
    end

    assert_equal(
      'type :foo is not allowed. Allowed types: :ok',
      err1.message
    )

    assert_equal(
      'type :bar is not allowed. Allowed types: :ok',
      err2.message
    )
  end

  test 'invalid handlers' do
    result = Divide.new.call(6, 2)

    err = assert_raises(Solid::Result::Contract::Error::UnexpectedType) do
      result.handle do |on|
        on.success(:foo) { :this_type_is_not_defined_in_the_expectations }
      end
    end

    assert_equal(
      'type :foo is not allowed. Allowed types: :ok',
      err.message
    )
  end

  test 'does not handle all cases' do
    err = assert_raises(Solid::Result::Error::UnhandledTypes) do
      Divide.new.call(6, 2).handle do |on|
        on.failure { :did_not_handle_all_expected_types }
      end
    end

    assert_equal(
      'You must handle all cases. This was not handled: :ok',
      err.message
    )
  end
end
