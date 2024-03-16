# frozen_string_literal: true

require 'test_helper'

module BCDD
  class ContextAndExposeFailureTest < Minitest::Test
    class Divide
      include BCDD::Context.mixin

      def call(arg1, arg2)
        validate_numbers(arg1, arg2)
          .and_then(:divide)
          .and_expose(:division_completed, %i[final_number])
      end

      private

      def validate_numbers(arg1, arg2)
        arg1.is_a?(Numeric) or return Failure(:invalid_arg, message: 'arg1 must be numeric')
        arg2.is_a?(Numeric) or return Failure(:invalid_arg, message: 'arg2 must be numeric')

        Success(:ok, number1: arg1, number2: arg2)
      end

      def divide(number1:, number2:)
        Success(:division_completed, final_number: (number1 / number2))
      end
    end

    test '#and_expose returns the failure itself if the result is a failure' do
      failure1 = Divide.new.call('12', 2)
      failure2 = Divide.new.call(12, '2')

      assert failure1.failure?(:invalid_arg)
      assert failure2.failure?(:invalid_arg)

      assert_equal({ message: 'arg1 must be numeric' }, failure1.value)
      assert_equal({ message: 'arg2 must be numeric' }, failure2.value)
    end
  end
end
