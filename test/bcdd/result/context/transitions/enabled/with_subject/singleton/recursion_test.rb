# frozen_string_literal: true

require 'test_helper'

class BCDD::Result
  class Context::TransitionsEnabledWithSubjectSingletonRecursionTest < Minitest::Test
    include BCDDResultTransitionAssertions

    module Fibonacci
      extend self, BCDD::Result::Context.mixin

      def call(input)
        BCDD::Result.transitions do
          require_valid_number(input).and_then do |output|
            number = output.fetch(:number)

            fibonacci = number <= 1 ? number : call(number - 1).value[:number] + call(number - 2).value[:number]

            Success(:fibonacci, number: fibonacci)
          end
        end
      end

      private

      def require_valid_number(input)
        input.is_a?(Numeric) or return Failure(:invalid_input, message: 'input must be numeric')

        input.negative? and return Failure(:negative_number, message: 'number cannot be negative')

        Success(:positive_number, number: input)
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
end
