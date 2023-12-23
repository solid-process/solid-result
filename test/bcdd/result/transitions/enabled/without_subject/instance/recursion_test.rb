# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::TransitionsEnabledWithoutSubjectInstanceRecursionTest < Minitest::Test
  class Fibonacci
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
    failure1 = Fibonacci.new.call('1')
    failure2 = Fibonacci.new.call(-1)

    fibonacci0 = Fibonacci.new.call(0)
    fibonacci1 = Fibonacci.new.call(1)
    fibonacci2 = Fibonacci.new.call(2)

    assert_equal(1, failure1.transitions.size)
    assert_equal(1, failure2.transitions.size)

    assert_equal(2, fibonacci0.transitions.size)
    assert_equal(2, fibonacci1.transitions.size)
    assert_equal(6, fibonacci2.transitions.size)
  end
end
