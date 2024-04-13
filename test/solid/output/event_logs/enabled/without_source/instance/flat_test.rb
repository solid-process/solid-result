# frozen_string_literal: true

require 'test_helper'

module Solid
  class Output::EventLogsEnabledWithoutSourceInstanceFlatTest < Minitest::Test
    include SolidResultEventLogAssertions

    class Division
      def call(num1, num2)
        Solid::Result.event_logs do
          validate_numbers(num1, num2)
            .and_then { |output| validate_nonzero(**output) }
            .and_then { |output| divide(**output) }
        end
      end

      private

      def validate_numbers(num1, num2)
        num1.is_a?(Numeric) or return Output::Failure(:invalid_arg, message: 'num1 must be numeric')
        num2.is_a?(Numeric) or return Output::Failure(:invalid_arg, message: 'num2 must be numeric')

        Output::Success(:ok, num1: num1, num2: num2)
      end

      def validate_nonzero(num2:, **)
        return Output::Failure(:division_by_zero, message: 'num2 cannot be zero') if num2.zero?

        Output::Success(:ok)
      end

      def divide(num1:, num2:)
        Output::Success(:ok, number: num1 / num2)
      end
    end

    test 'the tracking without nesting' do
      result1 = Division.new.call('4', 2)
      result2 = Division.new.call(4, '2')
      result3 = Division.new.call(4, 0)
      result4 = Division.new.call(4, 2)

      assert_event_logs(result1, size: 1)
      assert_event_logs(result2, size: 1)
      assert_event_logs(result3, size: 2)
      assert_event_logs(result4, size: 3)
    end

    test 'the tracking without nesting in different threads' do
      t1 = Thread.new { Division.new.call('4', 2) }
      t2 = Thread.new { Division.new.call(4, '2') }
      t3 = Thread.new { Division.new.call(4, 0) }
      t4 = Thread.new { Division.new.call(4, 2) }

      result1 = t1.value
      result2 = t2.value
      result3 = t3.value
      result4 = t4.value

      assert_event_logs(result1, size: 1)
      assert_event_logs(result2, size: 1)
      assert_event_logs(result3, size: 2)
      assert_event_logs(result4, size: 3)
    end

    test 'the standard error handling' do
      assert_raises(ZeroDivisionError) do
        Solid::Result.event_logs { 2 / 0 }
      end

      result1 = Division.new.call(4, 0)
      result2 = Division.new.call(4, 2)

      assert_event_logs(result1, size: 2)
      assert_event_logs(result2, size: 3)
    end

    test 'an exception handling' do
      assert_raises(NotImplementedError) do
        Solid::Result.event_logs { raise NotImplementedError }
      end

      result1 = Division.new.call(4, 2)
      result2 = Division.new.call(4, 0)

      assert_event_logs(result1, size: 3)
      assert_event_logs(result2, size: 2)
    end
  end
end
