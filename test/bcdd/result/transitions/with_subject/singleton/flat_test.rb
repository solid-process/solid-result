# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::TransitionsWithSubjectSingletonFlatTest < Minitest::Test
  module Division
    extend self, BCDD::Result.mixin

    def call(num1, num2)
      BCDD::Result.transitions do
        validate_numbers(num1, num2)
          .and_then(:validate_nonzero)
          .and_then(:divide)
      end
    end

    private

    def validate_numbers(num1, num2)
      num1.is_a?(Numeric) or return Failure(:invalid_arg, 'num1 must be numeric')
      num2.is_a?(Numeric) or return Failure(:invalid_arg, 'num2 must be numeric')

      Success(:ok, [num1, num2])
    end

    def validate_nonzero(numbers)
      return Failure(:division_by_zero, 'num2 must be different of zero') if numbers.last.zero?

      Success(:ok, numbers)
    end

    def divide((num1, num2))
      Success(:ok, num1 / num2)
    end
  end

  test 'the tracking without nesting' do
    result1 = Division.call('4', 2)
    result2 = Division.call(4, '2')
    result3 = Division.call(4, 0)
    result4 = Division.call(4, 2)

    assert_equal(1, result1.transitions.size)
    assert_equal(1, result2.transitions.size)
    assert_equal(2, result3.transitions.size)
    assert_equal(3, result4.transitions.size)
  end

  test 'the tracking without nesting in different threads' do
    t1 = Thread.new { Division.call('4', 2) }
    t2 = Thread.new { Division.call(4, '2') }
    t3 = Thread.new { Division.call(4, 0) }
    t4 = Thread.new { Division.call(4, 2) }

    result1 = t1.value
    result2 = t2.value
    result3 = t3.value
    result4 = t4.value

    assert_equal(1, result1.transitions.size)
    assert_equal(1, result2.transitions.size)
    assert_equal(2, result3.transitions.size)
    assert_equal(3, result4.transitions.size)
  end

  test 'the standard error handling' do
    assert_raises(ZeroDivisionError) do
      BCDD::Result.transitions { 2 / 0 }
    end

    result1 = Division.call(4, 0)
    result2 = Division.call(4, 2)

    assert_equal(2, result1.transitions.size)
    assert_equal(3, result2.transitions.size)
  end

  test 'an exception handling' do
    assert_raises(NotImplementedError) do
      BCDD::Result.transitions { raise ::NotImplementedError }
    end

    result1 = Division.call(4, 2)
    result2 = Division.call(4, 0)

    assert_equal(3, result1.transitions.size)
    assert_equal(2, result2.transitions.size)
  end
end
