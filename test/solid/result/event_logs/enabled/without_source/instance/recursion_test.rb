# frozen_string_literal: true

require 'test_helper'

class Solid::Result::EventLogsEnabledWithoutSourceInstanceRecursionTest < Minitest::Test
  include SolidResultEventLogAssertions

  class Fibonacci
    def call(input)
      Solid::Result.event_logs do
        require_valid_number(input).and_then do |number|
          fibonacci = number <= 1 ? number : call(number - 1).value + call(number - 2).value

          Solid::Result::Success(:fibonacci, fibonacci)
        end
      end
    end

    private

    def require_valid_number(input)
      input.is_a?(Numeric) or return Solid::Result::Failure(:invalid_input, 'input must be numeric')

      input.negative? and return Solid::Result::Failure(:invalid_number, 'number cannot be negative')

      Solid::Result::Success(:positive_number, input)
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
