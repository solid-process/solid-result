# frozen_string_literal: true

require 'test_helper'

class BCDD::Result
  class Context::TransitionsWithoutSubjectInstanceFlatTest < Minitest::Test
    class Division
      def call(num1, num2)
        BCDD::Result.transitions do
          validate_numbers(num1, num2)
            .and_then { |output| validate_nonzero(**output) }
            .and_then { |output| divide(**output) }
        end
      end

      private

      def validate_numbers(num1, num2)
        num1.is_a?(Numeric) or return Context::Failure(:invalid_arg, message: 'num1 must be numeric')
        num2.is_a?(Numeric) or return Context::Failure(:invalid_arg, message: 'num2 must be numeric')

        Context::Success(:ok, num1: num1, num2: num2)
      end

      def validate_nonzero(num2:, **)
        return Context::Failure(:division_by_zero, message: 'num2 must be different of zero') if num2.zero?

        Context::Success(:ok)
      end

      def divide(num1:, num2:)
        Context::Success(:ok, number: num1 / num2)
      end
    end

    test 'the tracking without nesting' do
      result1 = Division.new.call('4', 2)
      result2 = Division.new.call(4, '2')
      result3 = Division.new.call(4, 0)
      result4 = Division.new.call(4, 2)

      assert_equal(1, result1.transitions.size)
      assert_equal(1, result2.transitions.size)
      assert_equal(2, result3.transitions.size)
      assert_equal(3, result4.transitions.size)
    end

    test 'the tracking without nesting in different threads' do
      t1 = Thread.new { Division.new.call('4', 2) }
      t2 = Thread.new { Division.new.call(4, '2') }
      t3 = Thread.new { Division.new.call(4, 0) }
      t4 = Thread.new { Division.new.call(4, 2) }

      result1 = t1.value
      result2 = t2.value
      result3 = t3.value
      result4 = t4.value

      assert_equal(1, result1.transitions.size)
      assert_equal(1, result2.transitions.size)
      assert_equal(2, result3.transitions.size)
      assert_equal(3, result4.transitions.size)
    end

    test 'the standard error handling' do
      assert_raises(ZeroDivisionError) do
        BCDD::Result.transitions { 2 / 0 }
      end

      result1 = Division.new.call(4, 0)
      result2 = Division.new.call(4, 2)

      assert_equal(2, result1.transitions.size)
      assert_equal(3, result2.transitions.size)
    end

    test 'an exception handling' do
      assert_raises(NotImplementedError) do
        BCDD::Result.transitions { raise NotImplementedError }
      end

      result1 = Division.new.call(4, 2)
      result2 = Division.new.call(4, 0)

      assert_equal(3, result1.transitions.size)
      assert_equal(2, result2.transitions.size)
    end
  end
end
