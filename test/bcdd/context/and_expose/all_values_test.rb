# frozen_string_literal: true

require 'test_helper'

module BCDD
  class ContextAndExposeAllValuesTest < Minitest::Test
    class Divide
      include BCDD::Context.mixin

      def call(arg1, arg2)
        validate_numbers(arg1, arg2)
          .and_then(:divide, extra_division: 2)
          .and_expose(:division_completed, %i[final_number extra_division number1 number2])
      end

      private

      def validate_numbers(arg1, arg2)
        arg1.is_a?(Numeric) or return Failure(:invalid_arg, message: 'arg1 must be numeric')
        arg2.is_a?(Numeric) or return Failure(:invalid_arg, message: 'arg2 must be numeric')

        Success(:ok, number1: arg1, number2: arg2)
      end

      def divide(number1:, number2:, extra_division:)
        Success(:division_completed, final_number: (number1 / number2) / extra_division)
      end
    end

    test '#and_expose can expose all the values (accumulated or not)' do
      result = Divide.new.call(12, 2)

      assert result.success?(:division_completed)

      assert_equal(
        {
          final_number: 3,
          extra_division: 2,
          number1: 12,
          number2: 2
        },
        result.value
      )
    end
  end
end
