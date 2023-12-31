# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::TransitionsEnabledWithoutSubjectInstanceFlatTest < Minitest::Test
  include BCDDResultTransitionAssertions

  class Division
    include BCDD::Result.mixin

    def call(num1, num2)
      BCDD::Result.transitions do
        validate_numbers(num1, num2)
          .and_then { |numbers| validate_nonzero(numbers) }
          .and_then { |numbers| divide(numbers) }
      end
    end

    private

    def validate_numbers(num1, num2)
      num1.is_a?(Numeric) or return BCDD::Result::Failure(:invalid_arg, 'num1 must be numeric')
      num2.is_a?(Numeric) or return BCDD::Result::Failure(:invalid_arg, 'num2 must be numeric')

      BCDD::Result::Success(:ok, [num1, num2])
    end

    def validate_nonzero(numbers)
      return BCDD::Result::Failure(:division_by_zero, 'num2 cannot be zero') if numbers.last.zero?

      BCDD::Result::Success(:ok, numbers)
    end

    def divide((num1, num2))
      BCDD::Result::Success(:ok, num1 / num2)
    end
  end

  test 'the tracking without nesting' do
    result1 = Division.new.call('4', 2)
    result2 = Division.new.call(4, '2')
    result3 = Division.new.call(4, 0)
    result4 = Division.new.call(4, 2)

    assert_transitions(result1, size: 1)
    assert_transitions(result2, size: 1)
    assert_transitions(result3, size: 2)
    assert_transitions(result4, size: 3)
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

    assert_transitions(result1, size: 1)
    assert_transitions(result2, size: 1)
    assert_transitions(result3, size: 2)
    assert_transitions(result4, size: 3)
  end

  test 'the standard error handling' do
    assert_raises(ZeroDivisionError) do
      BCDD::Result.transitions { 2 / 0 }
    end

    result1 = Division.new.call(4, 0)
    result2 = Division.new.call(4, 2)

    assert_transitions(result1, size: 2)
    assert_transitions(result2, size: 3)
  end

  test 'an exception handling' do
    assert_raises(NotImplementedError) do
      BCDD::Result.transitions { raise ::NotImplementedError }
    end

    result1 = Division.new.call(4, 2)
    result2 = Division.new.call(4, 0)

    assert_transitions(result1, size: 3)
    assert_transitions(result2, size: 2)
  end
end
