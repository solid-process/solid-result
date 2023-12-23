# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::TransitionsDisabledWithoutSubjectNestedTest < Minitest::Test
  def setup
    BCDD::Result.config.feature.disable!(:transitions)
  end

  def teardown
    BCDD::Result.config.feature.enable!(:transitions)
  end

  class Division
    def call(num1, num2)
      BCDD::Result.transitions do
        validate_numbers(num1, num2)
          .and_then { |numbers| validate_nonzero(numbers) }
          .and_then { |numbers| divide(numbers) }
      end
    end

    private

    def validate_numbers(num1, num2)
      num1.is_a?(Numeric) or return BCDD::Result::Failure(:invalid_arg, 'num1 must be numeric')
      num2.is_a?(Numeric) or return BCDD::Result::Failure(:invalid_arg, 'num2 must be numeric')

      BCDD::Result::Success(:ok, [num1, num2])
    end

    def validate_nonzero(numbers)
      return Failure(:division_by_zero, 'num2 must be different of zero') if numbers.last.zero?

      BCDD::Result::Success(:ok, numbers)
    end

    def divide((num1, num2))
      BCDD::Result::Success(:ok, num1 / num2)
    end
  end

  module SumDivisionsByTwo
    extend self

    def call(*numbers)
      BCDD::Result.transitions do
        divisions = numbers.map { divide_by_two(_1) }

        if divisions.any?(&:failure?)
          BCDD::Result::Failure(:errors, divisions.select(&:failure?).map(&:value))
        else
          BCDD::Result::Success(:sum, divisions.sum(&:value))
        end
      end
    end

    private

    def divide_by_two(num)
      Division.new.call(num, 2)
    end
  end

  test 'nested transitions tracking' do
    result1 = SumDivisionsByTwo.call('30', '20', '10')
    result2 = SumDivisionsByTwo.call(30, '20', '10')
    result3 = SumDivisionsByTwo.call(30, 20, '10')
    result4 = SumDivisionsByTwo.call(30, 20, 10)

    assert_equal(0, result1.transitions.size)
    assert_equal(0, result2.transitions.size)
    assert_equal(0, result3.transitions.size)
    assert_equal(0, result4.transitions.size)
  end

  test 'nested transitions tracking in different threads' do
    t1 = Thread.new { SumDivisionsByTwo.call('30', '20', '10') }
    t2 = Thread.new { SumDivisionsByTwo.call(30, '20', '10') }
    t3 = Thread.new { SumDivisionsByTwo.call(30, 20, '10') }
    t4 = Thread.new { SumDivisionsByTwo.call(30, 20, 10) }

    result1 = t1.value
    result2 = t2.value
    result3 = t3.value
    result4 = t4.value

    assert_equal(0, result1.transitions.size)
    assert_equal(0, result2.transitions.size)
    assert_equal(0, result3.transitions.size)
    assert_equal(0, result4.transitions.size)
  end

  test 'the standard error handling' do
    assert_raises(ZeroDivisionError) do
      BCDD::Result.transitions { 2 / 0 }
    end

    result1 = SumDivisionsByTwo.call(30, 20, '10')
    result2 = SumDivisionsByTwo.call(30, 20, 10)

    assert_equal(0, result1.transitions.size)
    assert_equal(0, result2.transitions.size)
  end

  test 'an exception error handling' do
    assert_raises(NotImplementedError) do
      BCDD::Result.transitions { raise NotImplementedError }
    end

    result1 = SumDivisionsByTwo.call(30, 20, 10)
    result2 = SumDivisionsByTwo.call(30, 20, '10')

    assert_equal(0, result1.transitions.size)
    assert_equal(0, result2.transitions.size)
  end
end
