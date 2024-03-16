# frozen_string_literal: true

require 'test_helper'

module BCDD
  class Context::EventLogsEnabledWithSourceInstanceNestedTest < Minitest::Test
    include BCDDResultEventLogAssertions

    class Division
      include Context.mixin

      def call(num1, num2)
        BCDD::Result.event_logs do
          validate_numbers(num1, num2)
            .and_then(:validate_nonzero)
            .and_then(:divide)
        end
      end

      private

      def validate_numbers(num1, num2)
        num1.is_a?(Numeric) or return Failure(:invalid_arg, message: 'num1 must be numeric')
        num2.is_a?(Numeric) or return Failure(:invalid_arg, message: 'num2 must be numeric')

        Success(:ok, num1: num1, num2: num2)
      end

      def validate_nonzero(num2:, **)
        return Failure(:division_by_zero, message: 'num2 cannot be zero') if num2.zero?

        Success(:ok)
      end

      def divide(num1:, num2:)
        Success(:ok, number: num1 / num2)
      end
    end

    class SumDivisionsByTwo
      include Context.mixin

      def call(*numbers)
        BCDD::Result.event_logs do
          divisions = numbers.map { divide_by_two(_1) }

          if divisions.any?(&:failure?)
            Failure(:errors, errors: divisions.select(&:failure?).map(&:value))
          else
            Success(:sum, number: divisions.sum { _1.value[:number] })
          end
        end
      end

      private

      def divide_by_two(num)
        Division.new.call(num, 2)
      end
    end

    test 'nested event_logs tracking' do
      result1 = SumDivisionsByTwo.new.call('30', '20', '10')
      result2 = SumDivisionsByTwo.new.call(30, '20', '10')
      result3 = SumDivisionsByTwo.new.call(30, 20, '10')
      result4 = SumDivisionsByTwo.new.call(30, 20, 10)

      assert_event_logs(result1, size: 4)
      assert_event_logs(result2, size: 6)
      assert_event_logs(result3, size: 8)
      assert_event_logs(result4, size: 10)
    end

    test 'nested event_logs tracking in different threads' do
      t1 = Thread.new { SumDivisionsByTwo.new.call('30', '20', '10') }
      t2 = Thread.new { SumDivisionsByTwo.new.call(30, '20', '10') }
      t3 = Thread.new { SumDivisionsByTwo.new.call(30, 20, '10') }
      t4 = Thread.new { SumDivisionsByTwo.new.call(30, 20, 10) }

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
        BCDD::Result.event_logs { 2 / 0 }
      end

      result1 = SumDivisionsByTwo.new.call(30, 20, '10')
      result2 = SumDivisionsByTwo.new.call(30, 20, 10)

      assert_event_logs(result1, size: 8)
      assert_event_logs(result2, size: 10)
    end

    test 'an exception error handling' do
      assert_raises(NotImplementedError) do
        BCDD::Result.event_logs { raise NotImplementedError }
      end

      result1 = SumDivisionsByTwo.new.call(30, 20, 10)
      result2 = SumDivisionsByTwo.new.call(30, 20, '10')

      assert_event_logs(result1, size: 10)
      assert_event_logs(result2, size: 8)
    end
  end
end
