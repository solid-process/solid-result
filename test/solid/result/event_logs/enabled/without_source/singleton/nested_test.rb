# frozen_string_literal: true

require 'test_helper'

class Solid::Result::EventLogsEnabledWithoutSourceSingletonNestedTest < Minitest::Test
  include SolidResultEventLogAssertions

  module Division
    extend self

    def call(num1, num2)
      Solid::Result.event_logs do
        validate_numbers(num1, num2)
          .and_then { |numbers| validate_nonzero(numbers) }
          .and_then { |numbers| divide(numbers) }
      end
    end

    private

    def validate_numbers(num1, num2)
      num1.is_a?(Numeric) or return Solid::Result::Failure(:invalid_arg, 'num1 must be numeric')
      num2.is_a?(Numeric) or return Solid::Result::Failure(:invalid_arg, 'num2 must be numeric')

      Solid::Result::Success(:ok, [num1, num2])
    end

    def validate_nonzero(numbers)
      return Failure(:division_by_zero, 'num2 cannot be zero') if numbers.last.zero?

      Solid::Result::Success(:ok, numbers)
    end

    def divide((num1, num2))
      Solid::Result::Success(:ok, num1 / num2)
    end
  end

  module SumDivisionsByTwo
    extend self

    def call(*numbers)
      Solid::Result.event_logs do
        divisions = numbers.map { divide_by_two(_1) }

        if divisions.any?(&:failure?)
          Solid::Result::Failure(:errors, divisions.select(&:failure?).map(&:value))
        else
          Solid::Result::Success(:sum, divisions.sum(&:value))
        end
      end
    end

    private

    def divide_by_two(num)
      Division.call(num, 2)
    end
  end

  test 'nested event_logs tracking' do
    result1 = SumDivisionsByTwo.call('30', '20', '10')
    result2 = SumDivisionsByTwo.call(30, '20', '10')
    result3 = SumDivisionsByTwo.call(30, 20, '10')
    result4 = SumDivisionsByTwo.call(30, 20, 10)

    assert_event_logs(result1, size: 4)
    assert_event_logs(result2, size: 6)
    assert_event_logs(result3, size: 8)
    assert_event_logs(result4, size: 10)
  end

  test 'nested event_logs tracking in different threads' do
    t1 = Thread.new { SumDivisionsByTwo.call('30', '20', '10') }
    t2 = Thread.new { SumDivisionsByTwo.call(30, '20', '10') }
    t3 = Thread.new { SumDivisionsByTwo.call(30, 20, '10') }
    t4 = Thread.new { SumDivisionsByTwo.call(30, 20, 10) }

    result1 = t1.value
    result2 = t2.value
    result3 = t3.value
    result4 = t4.value

    assert_event_logs(result1, size: 4)
    assert_event_logs(result2, size: 6)
    assert_event_logs(result3, size: 8)
    assert_event_logs(result4, size: 10)
  end

  test 'the standard error handling' do
    assert_raises(ZeroDivisionError) do
      Solid::Result.event_logs { 2 / 0 }
    end

    result1 = SumDivisionsByTwo.call(30, 20, '10')
    result2 = SumDivisionsByTwo.call(30, 20, 10)

    assert_event_logs(result1, size: 8)
    assert_event_logs(result2, size: 10)
  end

  test 'an exception error handling' do
    assert_raises(NotImplementedError) do
      Solid::Result.event_logs { raise NotImplementedError }
    end

    result1 = SumDivisionsByTwo.call(30, 20, 10)
    result2 = SumDivisionsByTwo.call(30, 20, '10')

    assert_event_logs(result1, size: 10)
    assert_event_logs(result2, size: 8)
  end
end
