# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::EventLogsEnabledWithSourceInstanceNestedTest < Minitest::Test
  include BCDDResultEventLogAssertions

  class Division
    include BCDD::Result.mixin

    def call(num1, num2)
      BCDD::Result.event_logs(name: 'Division') do
        validate_numbers(num1, num2)
          .and_then(:divide, 'useless_arg')
      end
    end

    private

    def validate_numbers(num1, num2)
      num1.is_a?(Numeric) or return Failure(:invalid_arg, 'num1 must be numeric')
      num2.is_a?(Numeric) or return Failure(:invalid_arg, 'num2 must be numeric')

      Success(:ok, [num1, num2])
    end

    DetectZero = ->(number) do
      BCDD::Result.event_logs(name: 'DetectZero') do
        number.zero? ? BCDD::Result::Success(:is_zero) : BCDD::Result::Failure(:not_zero)
      end
    end

    CheckForZeros = ->((num1, num2)) do
      BCDD::Result.event_logs(name: 'CheckForZeros') do
        DetectZero[num2].handle do |on|
          on.success { BCDD::Result::Success(:num2_is_zero) }
          on.failure { num1.zero? ? BCDD::Result::Success(:num1_is_zero) : BCDD::Result::Failure(:no_zeros) }
        end
      end
    end

    def divide(numbers)
      CheckForZeros[numbers].handle do |on|
        on.success(:num2_is_zero) { Failure(:division_by_zero, 'num2 cannot be zero') }
        on.success(:num1_is_zero) { Success(:division_completed, 0) }
        on.failure { Success(:division_completed, numbers.first / numbers.last) }
      end
    end
  end

  class SumDivisionsByTwo
    include BCDD::Result.mixin

    def call(*numbers)
      BCDD::Result.event_logs(name: 'SumDivisionsByTwo') do
        divisions = numbers.map { divide_by_two(_1) }

        if divisions.any?(&:failure?)
          Failure(:errors, divisions.select(&:failure?).map(&:value))
        else
          Success(:sum, divisions.sum(&:value))
        end
      end
    end

    private

    def divide_by_two(num)
      Division.new.call(num, 2)
    end
  end

  test 'nested event_logs tracking' do
    result1 = SumDivisionsByTwo.new.call('30', '20', '10')
    result2 = SumDivisionsByTwo.new.call(30, '20', '10')
    result3 = SumDivisionsByTwo.new.call(30, 20, '10')
    result4 = SumDivisionsByTwo.new.call(30, 20, 10)

    assert_event_logs(result1, size: 4)
    assert_event_logs(result2, size: 7)
    assert_event_logs(result3, size: 10)
    assert_event_logs(result4, size: 13)
  end

  test 'nested event_logs tracking in different threads' do
    t1 = Thread.new { SumDivisionsByTwo.new.call('30', '20', '10') }
    t2 = Thread.new { SumDivisionsByTwo.new.call(30, '20', '10') }
    t3 = Thread.new { SumDivisionsByTwo.new.call(30, 20, '10') }
    t4 = Thread.new { SumDivisionsByTwo.new.call(30, 20, 10) }

    result1 = t1.value
    result2 = t2.value
    result3 = t3.value
    result4 = t4.value

    assert_event_logs(result1, size: 4)
    assert_event_logs(result2, size: 7)
    assert_event_logs(result3, size: 10)
    assert_event_logs(result4, size: 13)
  end

  test 'the standard error handling' do
    assert_raises(ZeroDivisionError) do
      BCDD::Result.event_logs { 2 / 0 }
    end

    result1 = SumDivisionsByTwo.new.call(30, 20, '10')
    result2 = SumDivisionsByTwo.new.call(30, 20, 10)

    assert_event_logs(result1, size: 10)
    assert_event_logs(result2, size: 13)
  end

  test 'an exception error handling' do
    assert_raises(NotImplementedError) do
      BCDD::Result.event_logs { raise NotImplementedError }
    end

    result1 = SumDivisionsByTwo.new.call(30, 20, 10)
    result2 = SumDivisionsByTwo.new.call(30, 20, '10')

    assert_event_logs(result1, size: 13)
    assert_event_logs(result2, size: 10)
  end

  test 'the tracking records (one level of nesting)' do
    result = SumDivisionsByTwo.new.call('30', '20', '10')

    last_event_log = result.event_logs[:records].last

    assert_equal(last_event_log.dig(:current, :id), last_event_log.dig(:root, :id))

    root = last_event_log.fetch(:current)

    assert_hash_schema!({ id: Integer, name: 'SumDivisionsByTwo', desc: nil }, root)

    {
      root: root,
      parent: root,
      current: { id: Integer, name: 'Division', desc: nil },
      result: { kind: :failure, type: :invalid_arg, value: 'num1 must be numeric', source: Division }
    }.then { |spec| assert_event_log_record(result, 0, spec) }

    {
      root: root,
      parent: root,
      current: { id: Integer, name: 'Division', desc: nil },
      result: { kind: :failure, type: :invalid_arg, value: 'num1 must be numeric', source: Division }
    }.then { |spec| assert_event_log_record(result, 1, spec) }

    {
      root: root,
      parent: root,
      current: { id: Integer, name: 'Division', desc: nil },
      result: { kind: :failure, type: :invalid_arg, value: 'num1 must be numeric', source: Division }
    }.then { |spec| assert_event_log_record(result, 2, spec) }

    {
      root: root,
      parent: root,
      current: root,
      result: { kind: :failure, type: :errors, value: ['num1 must be numeric'] * 3 }
    }.then { |spec| assert_event_log_record(result, 3, spec) }

    # ---

    assert_equal(4, result.event_logs[:records].map { _1.dig(:current, :id) }.uniq.size)

    assert_equal(4, result.event_logs[:records].map { _1[:time] }.tap { assert_equal(_1.sort, _1) }.uniq.size)
  end

  test 'the tracking records (multiple level of nesting)' do
    result = SumDivisionsByTwo.new.call('30', 20, 0)

    last_event_log = result.event_logs[:records].last

    assert_equal(last_event_log.dig(:current, :id), last_event_log.dig(:root, :id))

    root = last_event_log.fetch(:current)

    assert_hash_schema!({ id: Integer, name: 'SumDivisionsByTwo', desc: nil }, root)

    # 1st division event_log
    #
    {
      root: root,
      parent: root,
      current: { id: Integer, name: 'Division', desc: nil },
      result: { kind: :failure, type: :invalid_arg, value: 'num1 must be numeric', source: Division }
    }.then { |spec| assert_event_log_record(result, 0, spec) }

    # 2nd division event_logs
    #
    refute_equal(
      result.event_logs[:records][0].dig(:current, :id),
      result.event_logs[:records][1].dig(:current, :id)
    )

    {
      root: root,
      parent: root,
      current: { id: Integer, name: 'Division', desc: nil },
      result: { kind: :success, type: :ok, value: [20, 2], source: Division }
    }.then { |spec| assert_event_log_record(result, 1, spec) }

    {
      root: root,
      parent: { id: Integer, name: 'CheckForZeros', desc: nil },
      current: { id: Integer, name: 'DetectZero', desc: nil },
      result: { kind: :failure, type: :not_zero, value: nil, source: nil }
    }.then { |spec| assert_event_log_record(result, 2, spec) }

    {
      root: root,
      parent: { id: Integer, name: 'Division', desc: nil },
      current: { id: Integer, name: 'CheckForZeros', desc: nil },
      result: { kind: :failure, type: :no_zeros, value: nil, source: nil }
    }.then { |spec| assert_event_log_record(result, 3, spec) }

    {
      root: root,
      parent: root,
      current: { id: Integer, name: 'Division', desc: nil },
      result: { kind: :success, type: :division_completed, value: 10, source: Division },
      and_then: { type: :method, arg: 'useless_arg', method_name: :divide }
    }.then { |spec| assert_event_log_record(result, 4, spec) }

    # 3rd division event_logs
    #
    refute_equal(
      result.event_logs[:records][4].dig(:current, :id),
      result.event_logs[:records][5].dig(:current, :id)
    )

    {
      root: root,
      parent: root,
      current: { id: Integer, name: 'Division', desc: nil },
      result: { kind: :success, type: :ok, value: [0, 2], source: Division }
    }.then { |spec| assert_event_log_record(result, 5, spec) }

    {
      root: root,
      parent: { id: Integer, name: 'CheckForZeros', desc: nil },
      current: { id: Integer, name: 'DetectZero', desc: nil },
      result: { kind: :failure, type: :not_zero, value: nil, source: nil }
    }.then { |spec| assert_event_log_record(result, 6, spec) }

    {
      root: root,
      parent: { id: Integer, name: 'Division', desc: nil },
      current: { id: Integer, name: 'CheckForZeros', desc: nil },
      result: { kind: :success, type: :num1_is_zero, value: nil, source: nil }
    }.then { |spec| assert_event_log_record(result, 7, spec) }

    {
      root: root,
      parent: root,
      current: { id: Integer, name: 'Division', desc: nil },
      result: { kind: :success, type: :division_completed, value: 0, source: Division },
      and_then: { type: :method, arg: 'useless_arg', method_name: :divide }
    }.then { |spec| assert_event_log_record(result, 8, spec) }

    # Final result event_log

    {
      root: root,
      parent: root,
      current: root,
      result: { kind: :failure, type: :errors, value: ['num1 must be numeric'] }
    }.then { |spec| assert_event_log_record(result, 9, spec) }

    assert_equal(10, result.event_logs[:records].size)

    assert_equal(8, result.event_logs[:records].map { _1.dig(:current, :id) }.uniq.size)

    assert_equal(10, result.event_logs[:records].map { _1[:time] }.tap { assert_equal(_1.sort, _1) }.uniq.size)
  end
end
