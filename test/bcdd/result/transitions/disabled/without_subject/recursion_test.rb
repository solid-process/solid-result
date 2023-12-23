# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::TransitionsDisabledWithoutSubjectRecursionTest < Minitest::Test
  def setup
    BCDD::Result.config.feature.disable!(:transitions)
  end

  def teardown
    BCDD::Result.config.feature.enable!(:transitions)
  end

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

    assert_equal(0, failure1.transitions.size)
    assert_equal(0, failure2.transitions.size)

    assert_equal(0, fibonacci0.transitions.size)
    assert_equal(0, fibonacci1.transitions.size)
    assert_equal(0, fibonacci2.transitions.size)
  end
end
