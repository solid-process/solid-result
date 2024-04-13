# frozen_string_literal: true

require 'test_helper'

class Solid::Result::EventLogsEnabledWithSourceSingletonNestedTest < Minitest::Test
  include SolidResultEventLogAssertions

  module CheckForZeros
    extend self, Solid::Result.mixin(config: { addon: { continue: true } })

    def call(numbers)
      Solid::Result.event_logs(name: 'CheckForZeros') do
        Given(numbers)
          .and_then(:detect_zero, index: 1)
          .and_then(:detect_zero, index: 0)
          .then { _1.success?(:_continue_) ? Failure(:no_zeros, numbers) : _1 }
      end
    end

    private

    def detect_zero(numbers, ref)
      index = ref.fetch(:index)

      numbers[index].zero? ? Success(:"number#{index + 1}_is_zero", numbers) : Continue(numbers)
    end
  end

  module Division
    extend self, Solid::Result.mixin(config: { addon: { continue: true } })

    def call(num1, num2)
      Solid::Result.event_logs(name: 'Division') do
        Given([num1, num2])
          .and_then(:validate_numbers)
          .and_then(:check_for_zeros)
          .and_then(:divide)
      end
    end

    private

    def validate_numbers((num1, num2))
      num1.is_a?(Numeric) or return Failure(:invalid_arg, 'num1 must be numeric')
      num2.is_a?(Numeric) or return Failure(:invalid_arg, 'num2 must be numeric')

      Continue([num1, num2])
    end

    def check_for_zeros(numbers)
      CheckForZeros.call(numbers).handle do |on|
        on[:no_zeros] { Continue(numbers) }
        on[:number1_is_zero] { Success(:division_completed, 0) }
        on[:number2_is_zero] { Failure(:division_by_zero, 'num2 cannot be zero') }
      end
    end

    def divide((num1, num2))
      Success(:division_completed, num1 / num2)
    end
  end

  module SumDivisionsByTwo
    extend self, Solid::Result.mixin(config: { addon: { continue: true } })

    def call(*numbers)
      Solid::Result.event_logs(name: 'SumDivisionsByTwo') do
        Given(numbers)
          .and_then(:divide_numbers_by_two)
          .and_then(:sum_divisions)
      end
    end

    private

    def divide_numbers_by_two(numbers)
      divisions = numbers.map { Division.call(_1, 2) }

      Continue(divisions)
    end

    def sum_divisions(divisions)
      if divisions.any?(&:failure?)
        Failure(:errors, divisions.select(&:failure?).map(&:value))
      else
        Success(:sum, divisions.sum(&:value))
      end
    end
  end

  test 'nested event_logs tracking' do
    result1 = SumDivisionsByTwo.call('30', '20', '10')
    result2 = SumDivisionsByTwo.call(30, '20', '10')
    result3 = SumDivisionsByTwo.call(30, 20, '10')
    result4 = SumDivisionsByTwo.call(30, 20, 10)

    assert_event_logs(result1, size: 9)
    assert_event_logs(result2, size: 15)
    assert_event_logs(result3, size: 21)
    assert_event_logs(result4, size: 27)

    {
      root: { id: 0, name: 'SumDivisionsByTwo', desc: nil },
      parent: { id: 0, name: 'SumDivisionsByTwo', desc: nil },
      current: { id: 0, name: 'SumDivisionsByTwo', desc: nil },
      result: { kind: :success, type: :_given_, value: %w[30 20 10] }
    }.then { |spec| assert_event_log_record(result1, 0, spec) }

    assert_equal(
      [0, [[1, []], [2, []], [3, []]]],
      result1.event_logs[:metadata][:ids][:tree]
    )

    {
      root: { id: 0, name: 'SumDivisionsByTwo', desc: nil },
      parent: { id: 0, name: 'SumDivisionsByTwo', desc: nil },
      current: { id: 0, name: 'SumDivisionsByTwo', desc: nil },
      result: { kind: :success, type: :_given_, value: [30, '20', '10'] }
    }.then { |spec| assert_event_log_record(result2, 0, spec) }

    assert_equal(
      [0, [[1, [[2, []]]], [3, []], [4, []]]],
      result2.event_logs[:metadata][:ids][:tree]
    )

    {
      root: { id: 0, name: 'SumDivisionsByTwo', desc: nil },
      parent: { id: 0, name: 'SumDivisionsByTwo', desc: nil },
      current: { id: 0, name: 'SumDivisionsByTwo', desc: nil },
      result: { kind: :success, type: :_given_, value: [30, 20, '10'] }
    }.then { |spec| assert_event_log_record(result3, 0, spec) }

    assert_equal(
      [0, [[1, [[2, []]]], [3, [[4, []]]], [5, []]]],
      result3.event_logs[:metadata][:ids][:tree]
    )

    {
      root: { id: 0, name: 'SumDivisionsByTwo', desc: nil },
      parent: { id: 0, name: 'SumDivisionsByTwo', desc: nil },
      current: { id: 0, name: 'SumDivisionsByTwo', desc: nil },
      result: { kind: :success, type: :_given_, value: [30, 20, 10] }
    }.then { |spec| assert_event_log_record(result4, 0, spec) }

    assert_equal(
      [0, [[1, [[2, []]]], [3, [[4, []]]], [5, [[6, []]]]]],
      result4.event_logs[:metadata][:ids][:tree]
    )

    assert_predicate(result1.event_logs[:records][0][:and_then], :empty?)
    assert_predicate(result1.event_logs[:records][1][:and_then], :empty?)

    assert_equal(:validate_numbers, result1.event_logs[:records][2][:and_then][:method_name])

    assert_predicate(result1.event_logs[:records][3][:and_then], :empty?)
    assert_equal(:validate_numbers, result1.event_logs[:records][4][:and_then][:method_name])

    assert_predicate(result1.event_logs[:records][5][:and_then], :empty?)

    assert_equal(:validate_numbers, result1.event_logs[:records][6][:and_then][:method_name])
    assert_equal(:divide_numbers_by_two, result1.event_logs[:records][7][:and_then][:method_name])
    assert_equal(:sum_divisions, result1.event_logs[:records][8][:and_then][:method_name])
  end

  test 'nested event_logs tracking in different threads' do
    t1 = Thread.new { SumDivisionsByTwo.call('30', '20', '10') }
    t2 = Thread.new { SumDivisionsByTwo.call(30, '20', '10') }
    t3 = Thread.new { SumDivisionsByTwo.call(30, 20, '10') }
    t4 = Thread.new { SumDivisionsByTwo.call(30, 20, 10) }

    result1 = t1.value
    result2 = t2.value
    result3 = t3.value
    result4 = t4.value

    assert_event_logs(result1, size: 9)
    assert_event_logs(result2, size: 15)
    assert_event_logs(result3, size: 21)
    assert_event_logs(result4, size: 27)
  end

  test 'the standard error handling' do
    assert_raises(ZeroDivisionError) do
      Solid::Result.event_logs { 2 / 0 }
    end

    result1 = SumDivisionsByTwo.call(30, 20, '10')
    result2 = SumDivisionsByTwo.call(30, 20, 10)

    assert_event_logs(result1, size: 21)
    assert_event_logs(result2, size: 27)
  end

  test 'an exception error handling' do
    assert_raises(NotImplementedError) do
      Solid::Result.event_logs { raise NotImplementedError }
    end

    result1 = SumDivisionsByTwo.call(30, 20, 10)
    result2 = SumDivisionsByTwo.call(30, 20, '10')

    assert_event_logs(result1, size: 27)
    assert_event_logs(result2, size: 21)
  end
end
