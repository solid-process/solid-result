# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::TransitionsEnabledWithSubjectInstanceFlatTest < Minitest::Test
  include BCDDResultTransitionAssertions

  class Division
    include BCDD::Result.mixin(config: { addon: { continue: true } })

    def call(arg1, arg2)
      BCDD::Result.transitions(name: 'Division', desc: 'divide two numbers') do
        require_numbers(arg1, arg2)
          .and_then(:check_for_zeros)
          .and_then(:divide)
      end
    end

    private

    ValidNumber = ->(arg) { arg.is_a?(Numeric) && arg != Float::NAN && arg != Float::INFINITY }

    def require_numbers(arg1, arg2)
      ValidNumber[arg1] or return Failure(:invalid_arg, 'arg1 must be a valid number')
      ValidNumber[arg2] or return Failure(:invalid_arg, 'arg2 must be a valid number')

      Continue([arg1, arg2])
    end

    def check_for_zeros(numbers)
      num1, num2 = numbers

      return Failure(:division_by_zero, 'num2 cannot be zero') if num2.zero?

      num1.zero? ? Success(:division_completed, 0) : Continue(numbers)
    end

    def divide((num1, num2))
      Success(:division_completed, num1 / num2)
    end
  end

  test 'the tracking without nesting' do
    result1 = Division.new.call('4', 2)
    result2 = Division.new.call(4, '2')
    result3 = Division.new.call(4, 0)
    result4 = Division.new.call(0, 2)
    result5 = Division.new.call(4, 2)

    assert_transitions(result1, size: 1)
    assert_transitions(result2, size: 1)
    assert_transitions(result3, size: 2)
    assert_transitions(result4, size: 2)
    assert_transitions(result5, size: 3)
  end

  test 'the tracking without nesting in different threads' do
    t1 = Thread.new { Division.new.call('4', 2) }
    t2 = Thread.new { Division.new.call(4, '2') }
    t3 = Thread.new { Division.new.call(4, 0) }
    t4 = Thread.new { Division.new.call(0, 2) }
    t5 = Thread.new { Division.new.call(4, 2) }

    result1 = t1.value
    result2 = t2.value
    result3 = t3.value
    result4 = t4.value
    result5 = t5.value

    assert_transitions(result1, size: 1)
    assert_transitions(result2, size: 1)
    assert_transitions(result3, size: 2)
    assert_transitions(result4, size: 2)
    assert_transitions(result5, size: 3)
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
    result2 = Division.new.call(0, 2)

    assert_transitions(result1, size: 3)
    assert_transitions(result2, size: 2)
  end

  test 'the tracking records' do
    division1 = Division.new

    result1 = division1.call('4', 2)

    {
      result: { kind: :failure, type: :invalid_arg, value: 'arg1 must be a valid number' },
      and_then: ->(value) { value.is_a?(::Hash) && value.empty? }
    }.then { |spec| assert_division_transition(result1, 0, spec) }

    # ---

    division2 = Division.new

    result2 = division2.call(4, '2')

    {
      result: { kind: :failure, type: :invalid_arg, value: 'arg2 must be a valid number' },
      and_then: ->(value) { value.is_a?(::Hash) && value.empty? }
    }.then { |spec| assert_division_transition(result2, 0, spec) }

    # ---

    division3 = Division.new

    result3 = division3.call(4, 0)

    {
      result: { kind: :success, type: :continued, value: [4, 0] },
      and_then: ->(value) { value.is_a?(::Hash) && value.empty? }
    }.then { |spec| assert_division_transition(result3, 0, spec) }

    {
      result: { kind: :failure, type: :division_by_zero, value: 'num2 cannot be zero' },
      and_then: { type: :method, arg: nil, subject: division3, method_name: :check_for_zeros }
    }.then { |spec| assert_division_transition(result3, 1, spec) }

    # ---

    division4 = Division.new

    result4 = division4.call(0, 2)

    {
      result: { kind: :success, type: :continued, value: [0, 2] },
      and_then: ->(value) { value.is_a?(::Hash) && value.empty? }
    }.then { |spec| assert_division_transition(result4, 0, spec) }

    {
      result: { kind: :success, type: :division_completed, value: 0 },
      and_then: { type: :method, arg: nil, subject: division4, method_name: :check_for_zeros }
    }.then { |spec| assert_division_transition(result4, 1, spec) }

    # ---

    division5 = Division.new

    result5 = division5.call(4, 2)

    {
      result: { kind: :success, type: :continued, value: [4, 2] },
      and_then: ->(value) { value.is_a?(::Hash) && value.empty? }
    }.then { |spec| assert_division_transition(result5, 0, spec) }

    {
      result: { kind: :success, type: :continued, value: [4, 2] },
      and_then: { type: :method, arg: nil, subject: division5, method_name: :check_for_zeros }
    }.then { |spec| assert_division_transition(result5, 1, spec) }

    {
      result: { kind: :success, type: :division_completed, value: 2 },
      and_then: { type: :method, arg: nil, subject: division5, method_name: :divide }
    }.then { |spec| assert_division_transition(result5, 2, spec) }

    # ---

    assert_equal(1, result1.transitions[:records].map { [_1.dig(:root, :id), _1.dig(:current, :id)] }.flatten.uniq.size)
    assert_equal(1, result2.transitions[:records].map { [_1.dig(:root, :id), _1.dig(:current, :id)] }.flatten.uniq.size)
    assert_equal(1, result3.transitions[:records].map { [_1.dig(:root, :id), _1.dig(:current, :id)] }.flatten.uniq.size)
    assert_equal(1, result4.transitions[:records].map { [_1.dig(:root, :id), _1.dig(:current, :id)] }.flatten.uniq.size)
    assert_equal(1, result5.transitions[:records].map { [_1.dig(:root, :id), _1.dig(:current, :id)] }.flatten.uniq.size)

    assert_equal(
      [0],
      [result1, result2, result3, result4, result5]
        .map { |result| result.transitions[:records].map { _1.dig(:root, :id) }.uniq }.uniq.flatten
    )

    assert_equal(1, result1.transitions[:records].map { _1[:time] }.tap { assert_equal(_1.sort, _1) }.uniq.size)
    assert_equal(1, result2.transitions[:records].map { _1[:time] }.tap { assert_equal(_1.sort, _1) }.uniq.size)
    assert_equal(2, result3.transitions[:records].map { _1[:time] }.tap { assert_equal(_1.sort, _1) }.uniq.size)
    assert_equal(2, result4.transitions[:records].map { _1[:time] }.tap { assert_equal(_1.sort, _1) }.uniq.size)
    assert_equal(3, result5.transitions[:records].map { _1[:time] }.tap { assert_equal(_1.sort, _1) }.uniq.size)
  end

  def assert_division_transition(result, index, options)
    scope = {
      root: { id: Integer, name: 'Division', desc: 'divide two numbers' },
      parent: { id: Integer, name: 'Division', desc: 'divide two numbers' },
      current: { id: Integer, name: 'Division', desc: 'divide two numbers' }
    }

    assert_transition_record(result, index, scope.merge(options))
  end
end
