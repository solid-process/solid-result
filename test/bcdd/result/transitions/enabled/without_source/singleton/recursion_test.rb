# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::TransitionsEnabledWithoutSourceSingletonRecursionTest < Minitest::Test
  include BCDDResultTransitionAssertions

  module Fibonacci
    extend self

    def call(input)
      BCDD::Result.transitions do
        require_valid_number(input).and_then do |number|
          fibonacci = number <= 1 ? number : call(number - 1).value + call(number - 2).value

          BCDD::Result::Success(:fibonacci, fibonacci)
        end
      end
    end

    private

    def require_valid_number(input)
      input.is_a?(Numeric) or return BCDD::Result::Failure(:invalid_input, 'input must be numeric')

      input.negative? and return BCDD::Result::Failure(:invalid_number, 'number cannot be negative')

      BCDD::Result::Success(:positive_number, input)
    end
  end

  test 'transitions inside a recursion' do
    failure1 = Fibonacci.call('1')
    failure2 = Fibonacci.call(-1)

    fibonacci0 = Fibonacci.call(0)
    fibonacci1 = Fibonacci.call(1)
    fibonacci2 = Fibonacci.call(2)

    assert_transitions(failure1, size: 1)
    assert_transitions(failure2, size: 1)

    assert_transitions(fibonacci0, size: 2)
    assert_transitions(fibonacci1, size: 2)
    assert_transitions(fibonacci2, size: 6)
  end
end
