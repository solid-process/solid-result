# frozen_string_literal: true

require 'test_helper'

module BCDD
  class Context::TransitionsDisabledWithSourceInstanceNestedTest < Minitest::Test
    include BCDDResultTransitionAssertions

    def setup
      BCDD::Result.config.feature.disable!(:transitions)
    end

    def teardown
      BCDD::Result.config.feature.enable!(:transitions)
    end

    module Division
      extend self, Context.mixin

      def call(num1, num2)
        BCDD::Result.transitions do
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
        BCDD::Result.transitions do
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
        Division.call(num, 2)
      end
    end

    test 'nested transitions tracking' do
      result1 = SumDivisionsByTwo.new.call('30', '20', '10')
      result2 = SumDivisionsByTwo.new.call(30, '20', '10')
      result3 = SumDivisionsByTwo.new.call(30, 20, '10')
      result4 = SumDivisionsByTwo.new.call(30, 20, 10)

      assert_empty_transitions(result1)
      assert_empty_transitions(result2)
      assert_empty_transitions(result3)
      assert_empty_transitions(result4)
    end

    test 'nested transitions tracking in different threads' do
      t1 = Thread.new { SumDivisionsByTwo.new.call('30', '20', '10') }
      t2 = Thread.new { SumDivisionsByTwo.new.call(30, '20', '10') }
      t3 = Thread.new { SumDivisionsByTwo.new.call(30, 20, '10') }
      t4 = Thread.new { SumDivisionsByTwo.new.call(30, 20, 10) }

      result1 = t1.value
      result2 = t2.value
      result3 = t3.value
      result4 = t4.value

      assert_empty_transitions(result1)
      assert_empty_transitions(result2)
      assert_empty_transitions(result3)
      assert_empty_transitions(result4)
    end

    test 'the standard error handling' do
      assert_raises(ZeroDivisionError) do
        BCDD::Result.transitions { 2 / 0 }
      end

      result1 = SumDivisionsByTwo.new.call(30, 20, '10')
      result2 = SumDivisionsByTwo.new.call(30, 20, 10)

      assert_empty_transitions(result1)
      assert_empty_transitions(result2)
    end

    test 'an exception error handling' do
      assert_raises(NotImplementedError) do
        BCDD::Result.transitions { raise NotImplementedError }
      end

      result1 = SumDivisionsByTwo.new.call(30, 20, 10)
      result2 = SumDivisionsByTwo.new.call(30, 20, '10')

      assert_empty_transitions(result1)
      assert_empty_transitions(result2)
    end
  end
end
