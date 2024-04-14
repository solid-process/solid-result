# frozen_string_literal: true

require 'test_helper'

class Solid::Result::ExpectationsWithSourceSuccessAndFailureTypeTest < Minitest::Test
  class Divide
    include Solid::Result::Expectations.mixin(
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

      Success(:ok, [arg1, arg2])
    end

    def validate_non_zero(numbers)
      return Success(:ok, numbers) unless numbers.last.zero?

      Failure(:err, 'arg2 must not be zero')
    end

    def divide((number1, number2))
      Success(:ok, number1 / number2)
    end
  end

  test 'valid execution' do
    result = Divide.new.call(10, 2)

    assert result.success?(:ok)

    assert_predicate result, :success?

    # --

    result = Divide.new.call(10, 0)

    assert result.failure?(:err)

    assert_predicate result, :failure?
  end

  test 'valid hooks' do
    increment = 0

    result = Divide.new.call(10, 5)

    result
      .on_failure { increment += 1 }
      .on_success { increment += 1 }
      .on_success(:ok) { increment += 1 }

    assert_equal 2, increment

    # ---

    decrement = 2

    result = Divide.new.call(10, 0)

    result
      .on_success { decrement -= 1 }
      .on_failure { decrement -= 1 }
      .on_failure(:err) { decrement -= 1 }

    assert_equal 0, decrement
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

    # ---

    decrement = 2

    Divide.new.call(10, '2').handle do |on|
      on.success { decrement -= 1 }
      on.failure { decrement -= 1 }
      on.failure(:err) { decrement -= 1 }
    end

    Divide.new.call(10, '0').handle do |on|
      on.success { decrement -= 1 }
      on.failure(:err) { decrement -= 1 }
      on.failure { decrement -= 1 }
    end

    assert_equal 0, decrement
  end

  test 'invalid result type' do
    err1 = assert_raises(Solid::Result::Contract::Error::UnexpectedType) do
      Divide.new.call(10, 2).success?(:division_completed)
    end

    assert_equal(
      'type :division_completed is not allowed. Allowed types: :ok',
      err1.message
    )

    # ---

    err2 = assert_raises(Solid::Result::Contract::Error::UnexpectedType) do
      Divide.new.call(10, '2').failure?(:division_by_zero)
    end

    assert_equal(
      'type :division_by_zero is not allowed. Allowed types: :err',
      err2.message
    )
  end

  test 'invalid hooks' do
    result = Divide.new.call(6, 2)

    err1 = assert_raises(Solid::Result::Contract::Error::UnexpectedType) do
      result.on_success(:division_completed) { :this_type_is_not_defined_in_the_expectations }
    end

    err2 = assert_raises(Solid::Result::Contract::Error::UnexpectedType) do
      result.on_failure(:invalid_arg) { :this_type_is_not_defined_in_the_expectations }
    end

    err3 = assert_raises(Solid::Result::Contract::Error::UnexpectedType) do
      result.on(:bar) { :this_type_is_not_defined_in_the_expectations }
    end

    assert_equal(
      'type :division_completed is not allowed. Allowed types: :ok',
      err1.message
    )

    assert_equal(
      'type :invalid_arg is not allowed. Allowed types: :err',
      err2.message
    )

    assert_equal(
      'type :bar is not allowed. Allowed types: :ok, :err',
      err3.message
    )
  end

  test 'invalid handlers' do
    result = Divide.new.call(6, 2)

    err1 = assert_raises(Solid::Result::Contract::Error::UnexpectedType) do
      result.handle do |on|
        on.success(:division_completed) { :this_type_is_not_defined_in_the_expectations }
      end
    end

    err2 = assert_raises(Solid::Result::Contract::Error::UnexpectedType) do
      result.handle do |on|
        on.failure(:division_by_zero) { :this_type_is_not_defined_in_the_expectations }
      end
    end

    err3 = assert_raises(Solid::Result::Contract::Error::UnexpectedType) do
      result.handle do |on|
        on.type(:foo) { :this_type_is_not_defined_in_the_expectations }
      end
    end

    assert_equal(
      'type :division_completed is not allowed. Allowed types: :ok',
      err1.message
    )

    assert_equal(
      'type :division_by_zero is not allowed. Allowed types: :err',
      err2.message
    )

    assert_equal(
      'type :foo is not allowed. Allowed types: :ok, :err',
      err3.message
    )
  end

  test 'does not handle all cases' do
    err1 = assert_raises(Solid::Result::Error::UnhandledTypes) do
      Divide.new.call(6, 2).handle do |on|
        on.success(:ok) { :did_not_handle_all_expected_types }
      end
    end

    err2 = assert_raises(Solid::Result::Error::UnhandledTypes) do
      Divide.new.call(6, '2').handle do |on|
        on.success { :did_not_handle_all_expected_types }
      end
    end

    err3 = assert_raises(Solid::Result::Error::UnhandledTypes) do
      Divide.new.call(8, '2').handle do |on|
        on.failure { :did_not_handle_all_expected_types }
      end
    end

    err4 = assert_raises(Solid::Result::Error::UnhandledTypes) do
      Divide.new.call(6, 2).handle do |on|
        on.failure(:err) { :did_not_handle_all_expected_types }
      end
    end

    err5 = assert_raises(Solid::Result::Error::UnhandledTypes) do
      Divide.new.call(6, 2).handle do |on|
        on.type(:ok) { :did_not_handle_all_expected_types }
      end
    end

    err6 = assert_raises(Solid::Result::Error::UnhandledTypes) do
      Divide.new.call(6, 2).handle do |on|
        on.type(:err) { :did_not_handle_all_expected_types }
      end
    end

    assert_equal(
      'You must handle all cases. This was not handled: :err',
      err1.message
    )

    assert_equal(
      'You must handle all cases. This was not handled: :err',
      err2.message
    )

    assert_equal(
      'You must handle all cases. This was not handled: :ok',
      err3.message
    )

    assert_equal(
      'You must handle all cases. This was not handled: :ok',
      err4.message
    )

    assert_equal(
      'You must handle all cases. This was not handled: :err',
      err5.message
    )

    assert_equal(
      'You must handle all cases. This was not handled: :ok',
      err6.message
    )
  end
end
