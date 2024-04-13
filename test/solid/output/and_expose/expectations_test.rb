# frozen_string_literal: true

require 'test_helper'

module Solid
  class OutputExpectationsTest < Minitest::Test
    class Divide1
      include Solid::Output::Expectations.mixin(
        config: { addon: { continue: true } },
        success: { division_completed: ->(value) { value[:final_number].is_a?(Numeric) } },
        failure: { invalid_arg: ->(value) { value[:message].is_a?(String) } }
      )

      def call(arg1, arg2)
        validate_numbers(arg1, arg2)
          .and_then(:divide)
          .and_expose(:division_completed, %i[final_number])
      end

      private

      def validate_numbers(arg1, arg2)
        arg1.is_a?(Numeric) or return Failure(:invalid_arg, message: 'arg1 must be numeric')
        arg2.is_a?(Numeric) or return Failure(:invalid_arg, message: 'arg2 must be numeric')

        Continue(number1: arg1, number2: arg2)
      end

      def divide(number1:, number2:)
        Continue(final_number: (number1 / number2).to_s)
      end
    end

    class Divide2
      include Solid::Output::Expectations.mixin(
        config: { addon: { continue: true } },
        success: { division_completed: ->(value) { value[:final_number].is_a?(Numeric) } },
        failure: { invalid_arg: ->(value) { value[:message].is_a?(String) } }
      )

      def call(arg1, arg2)
        validate_numbers(arg1, arg2)
          .and_then(:divide)
          .and_expose(:ok, %i[final_number])
      end

      private

      def validate_numbers(arg1, arg2)
        arg1.is_a?(Numeric) or return Failure(:invalid_arg, message: 'arg1 must be numeric')
        arg2.is_a?(Numeric) or return Failure(:invalid_arg, message: 'arg2 must be numeric')

        Continue(number1: arg1, number2: arg2)
      end

      def divide(number1:, number2:)
        Continue(final_number: (number1 / number2))
      end
    end

    test '#and_expose validates the exposed value' do
      err1 = assert_raises(Solid::Result::Contract::Error::UnexpectedValue) do
        Divide1.new.call(12, 2)
      end

      assert_equal('value {:final_number=>"6"} is not allowed for :division_completed type', err1.message)

      err2 = assert_raises(Solid::Result::Contract::Error::UnexpectedType) do
        Divide2.new.call(12, 2)
      end

      assert_equal('type :ok is not allowed. Allowed types: :division_completed', err2.message)
    end
  end
end
