# frozen_string_literal: true

require 'test_helper'

class Solid::Result::EventLogsDisabledWithoutSourceRecursionTest < Minitest::Test
  include SolidResultEventLogAssertions

  def setup
    Solid::Result.config.feature.disable!(:event_logs)
  end

  def teardown
    Solid::Result.config.feature.enable!(:event_logs)
  end

  module Fibonacci
    extend self

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
    failure1 = Fibonacci.call('1')
    failure2 = Fibonacci.call(-1)

    fibonacci0 = Fibonacci.call(0)
    fibonacci1 = Fibonacci.call(1)
    fibonacci2 = Fibonacci.call(2)

    assert_empty_event_logs(failure1)
    assert_empty_event_logs(failure2)

    assert_empty_event_logs(fibonacci0)
    assert_empty_event_logs(fibonacci1)
    assert_empty_event_logs(fibonacci2)
  end
end
