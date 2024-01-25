# frozen_string_literal: true

require 'test_helper'

class BCDD::Result
  class ContextAndExposeInvalidKeysTest < Minitest::Test
    class Divide
      include BCDD::Result::Context.mixin

      def call(arg1, arg2)
        validate_numbers(arg1, arg2)
          .and_then(:divide, extra_division: 2)
          .and_expose(:division_completed, %i[final_numbers extra_division number1 number2])
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

    test '#and_expose receive an invalid key' do
      err = assert_raises(BCDD::Result::Context::Error::InvalidExposure) { Divide.new.call(12, 2) }

      assert err.message.start_with?('key not found: :final_numbers')
      assert err.message.end_with?('. Available to expose: :number1, :number2, :extra_division, :final_number')
    end
  end
end
