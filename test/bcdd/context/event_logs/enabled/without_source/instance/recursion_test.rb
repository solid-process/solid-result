# frozen_string_literal: true

require 'test_helper'

module BCDD
  class Context::EventLogsEnabledWithoutSourceInstanceRecursionTest < Minitest::Test
    include BCDDResultEventLogAssertions

    class Fibonacci
      def call(input)
        BCDD::Result.event_logs do
          require_valid_number(input).and_then do |output|
            number = output.fetch(:number)

            fibonacci = number <= 1 ? number : call(number - 1).value[:number] + call(number - 2).value[:number]

            Context::Success(:fibonacci, number: fibonacci)
          end
        end
      end

      private

      def require_valid_number(input)
        input.is_a?(Numeric) or return Context::Failure(:invalid_input, message: 'input must be numeric')

        input.negative? and return Context::Failure(:negative_number, message: 'number cannot be negative')

        Context::Success(:positive_number, number: input)
      end
    end

    test 'event_logs inside a recursion' do
      failure1 = Fibonacci.new.call('1')
      failure2 = Fibonacci.new.call(-1)

      fibonacci0 = Fibonacci.new.call(0)
      fibonacci1 = Fibonacci.new.call(1)
      fibonacci2 = Fibonacci.new.call(2)

      assert_event_logs(failure1, size: 1)
      assert_event_logs(failure2, size: 1)

      assert_event_logs(fibonacci0, size: 2)
      assert_event_logs(fibonacci1, size: 2)
      assert_event_logs(fibonacci2, size: 6)
    end
  end
end
