# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::TransitionsTest < Minitest::Test
  test 'transitions is empty by default' do
    success = BCDD::Result::Success(:ok, 1)
    failure = BCDD::Result::Failure(:err, 0)

    assert_instance_of(Array, success.transitions)
    assert(success.transitions.empty? && success.transitions.frozen?)

    assert_instance_of(Array, failure.transitions)
    assert(failure.transitions.empty? && failure.transitions.frozen?)
  end

  test 'invalid transitions block output' do
    err = assert_raises(BCDD::Result::Error::UnexpectedOutcome) do
      BCDD::Result.transitions { 1 }
    end

    assert_equal(
      'Unexpected outcome: 1. The transitions must return this object wrapped by ' \
      'BCDD::Result::Success or BCDD::Result::Failure',
      err.message
    )
  end

  class Division
    include BCDD::Result.mixin

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

  test 'the result tracking' do
    result1 = Division.new.call('4', 2)
    result2 = Division.new.call(4, '2')
    result3 = Division.new.call(4, 0)
    result4 = Division.new.call(4, 2)

    assert_equal(1, result1.transitions.size)
    assert_equal(1, result2.transitions.size)
    assert_equal(2, result3.transitions.size)
    assert_equal(3, result4.transitions.size)
  end

  test 'the result tracking in different threads' do
    t1 = Thread.new { Division.new.call('4', 2) }
    t2 = Thread.new { Division.new.call(4, '2') }
    t3 = Thread.new { Division.new.call(4, 0) }
    t4 = Thread.new { Division.new.call(4, 2) }

    result1 = t1.value
    result2 = t2.value
    result3 = t3.value
    result4 = t4.value

    assert_equal(1, result1.transitions.size)
    assert_equal(1, result2.transitions.size)
    assert_equal(2, result3.transitions.size)
    assert_equal(3, result4.transitions.size)
  end

  class SumDivisionsByTwo
    include BCDD::Result.mixin

    def call(*numbers)
      BCDD::Result.transitions do
        divisions = numbers.map { divide_by_two(_1) }

        if divisions.any?(&:failure?)
          Failure(:errors, divisions.select(&:failure?).map(&:value))
        else
          Success(:sum, divisions.sum(&:value))
        end
      end
    end

    private

    def divide_by_two(num)
      Division.new.call(num, 2)
    end
  end

  test 'nested transitions' do
    result1 = SumDivisionsByTwo.new.call('30', '20', '10')
    result2 = SumDivisionsByTwo.new.call(30, '20', '10')
    result3 = SumDivisionsByTwo.new.call(30, 20, '10')
    result4 = SumDivisionsByTwo.new.call(30, 20, 10)

    assert_equal(4, result1.transitions.size)
    assert_equal(6, result2.transitions.size)
    assert_equal(8, result3.transitions.size)
    assert_equal(10, result4.transitions.size)
  end
end
