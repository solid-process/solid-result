# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::EventLogsDisabledWithSourceRecursionTest < Minitest::Test
  include BCDDResultEventLogAssertions

  def setup
    BCDD::Result.config.feature.disable!(:event_logs)
  end

  def teardown
    BCDD::Result.config.feature.enable!(:event_logs)
  end

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
      input.is_a?(Numeric) or return Failure(:invalid_input, 'input must be numeric')

      input.negative? and return Failure(:invalid_number, 'number cannot be negative')

      Success(:positive_number, input)
    end
  end

  test 'event_logs inside a recursion' do
    failure1 = Fibonacci.new.call('1')
    failure2 = Fibonacci.new.call(-1)

    fibonacci0 = Fibonacci.new.call(0)
    fibonacci1 = Fibonacci.new.call(1)
    fibonacci2 = Fibonacci.new.call(2)

    assert_empty_event_logs(failure1)
    assert_empty_event_logs(failure2)

    assert_empty_event_logs(fibonacci0)
    assert_empty_event_logs(fibonacci1)
    assert_empty_event_logs(fibonacci2)
  end
end
