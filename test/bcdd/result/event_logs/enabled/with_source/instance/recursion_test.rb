# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::EventLogsEnabledWithSourceInstanceRecursionTest < Minitest::Test
  include BCDDResultEventLogAssertions

  class Fibonacci
    include BCDD::Result.mixin

    def call(input)
      BCDD::Result.event_logs do
        require_valid_number(input).and_then do |number|
          fibonacci = number <= 1 ? number : call(number - 1).value + call(number - 2).value

          Success(:fibonacci, fibonacci)
        end
      end
    end

    private

    def require_valid_number(input)
      input.is_a?(Numeric) or return Failure(:not_a_number, 'input must be numeric')

      input.negative? and return Failure(:negative_number, 'number cannot be negative')

      Success(:number_gte_zero, input)
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
