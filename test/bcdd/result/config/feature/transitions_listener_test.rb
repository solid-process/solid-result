# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::Config
  class FeatureTransitionsListenerTest < Minitest::Test
    include BCDDResultTransitionAssertions

    class Division
      include BCDD::Result.mixin(config: { addon: { continue: true } })

      def call(arg1, arg2)
        BCDD::Result.transitions(name: 'Division') do
          Given([arg1, arg2])
            .and_then(:require_numbers)
            .and_then(:check_for_zeros)
            .and_then(:divide)
        end
      end

      private

      ValidNumber = ->(arg) { arg.is_a?(Numeric) && (!arg.respond_to?(:finite?) || arg.finite?) }

      def require_numbers((arg1, arg2))
        ValidNumber[arg1] or return Failure(:invalid_arg, 'arg1 must be a valid number')
        ValidNumber[arg2] or return Failure(:invalid_arg, 'arg2 must be a valid number')

        Continue([arg1, arg2])
      end

      def check_for_zeros(numbers)
        numbers.first.zero? ? Success(:division_completed, 0) : Continue(numbers)
      end

      def divide((num1, num2))
        Success(:division_completed, num1 / num2)
      end
    end

    module InspectListener
      extend BCDD::Result::Transitions::Listener

      class << self
        attr_reader :memo

        def new
          tap { @memo = Hash.new { |hash, key| hash[key] = [] } }
        end

        def on_start(scope:)
          memo[:on_start] << scope
        end

        def around_transitions(scope:)
          memo[:around_transitions] << scope

          yield
        end

        def around_and_then(scope:, and_then:)
          memo[:around_and_then] << { scope: scope, and_then: and_then }

          yield
        end

        def on_record(record:)
          memo[:on_record] << record
        end

        def on_finish(transitions:)
          memo[:on_finish] << transitions
        end

        def before_interruption(exception:, transitions:)
          memo[:before_interruption] << { exception: exception, transitions: transitions }
        end
      end
    end

    test 'valid listener config (without transitions interruption)' do
      original_listener = BCDD::Result.config.transitions.listener

      BCDD::Result.config.transitions.listener = InspectListener

      result = Division.new.call(10, 2)

      scope = { id: 0, name: 'Division', desc: nil }

      assert_equal([scope], InspectListener.memo[:on_start])

      assert_equal([scope], InspectListener.memo[:around_transitions])

      [
        { scope: scope, and_then: { type: :method, arg: nil, method_name: :require_numbers } },
        { scope: scope, and_then: { type: :method, arg: nil, method_name: :check_for_zeros } },
        { scope: scope, and_then: { type: :method, arg: nil, method_name: :divide } }
      ].each_with_index do |and_then, index|
        assert_equal(and_then, InspectListener.memo[:around_and_then][index])
      end

      result.transitions[:records].each_with_index do |record, index|
        assert_equal(record, InspectListener.memo[:on_record][index])
      end

      assert_equal(result.transitions, InspectListener.memo[:on_finish].first)
    ensure
      BCDD::Result.config.transitions.listener = original_listener
    end

    test 'valid listener config (with transitions interruption)' do
      original_listener = BCDD::Result.config.transitions.listener

      BCDD::Result.config.transitions.listener = InspectListener

      assert_raises(ZeroDivisionError, 'divided by 0') { Division.new.call(10, 0) }

      scope = { id: 0, name: 'Division', desc: nil }

      assert_equal([scope], InspectListener.memo[:on_start])

      assert_equal([scope], InspectListener.memo[:around_transitions])

      [
        { scope: scope, and_then: { type: :method, arg: nil, method_name: :require_numbers } },
        { scope: scope, and_then: { type: :method, arg: nil, method_name: :check_for_zeros } },
        { scope: scope, and_then: { type: :method, arg: nil, method_name: :divide } }
      ].each_with_index do |and_then, index|
        assert_equal(and_then, InspectListener.memo[:around_and_then][index])
      end

      on_record = InspectListener.memo[:on_record]

      assert_equal(3, on_record.size)
      assert_equal(:given, on_record.dig(0, :result, :type))
      assert_equal(:require_numbers, on_record.dig(1, :and_then, :method_name))
      assert_equal(:check_for_zeros, on_record.dig(2, :and_then, :method_name))

      before_interruption = InspectListener.memo[:before_interruption].first

      assert_instance_of(ZeroDivisionError, before_interruption[:exception])

      assert_transitions!(before_interruption[:transitions], size: 3)

      assert_equal(on_record, before_interruption[:transitions][:records])
    ensure
      BCDD::Result.config.transitions.listener = original_listener
    end

    test 'invalid listener config' do
      err = assert_raises(ArgumentError) { BCDD::Result.config.transitions.listener = 1 }

      assert_equal('1 must be a BCDD::Result::Transitions::Listener', err.message)
    end

    class BrokenListener
      include BCDD::Result::Transitions::Listener

      def initialize
        raise 'broken'
      end
    end

    test 'broken listener' do
      original_listener = BCDD::Result.config.transitions.listener

      BCDD::Result.config.transitions.listener = BrokenListener

      stderr1 = /Fallback to BCDD::Result::Transitions::Listener::Null because registered listener raised an exception:/

      assert_output(nil, stderr1) { Division.new.call(1, 2) }

      stderr2 = /raised an exception: broken \(RuntimeError\); Backtrace:.+/

      assert_output(nil, stderr2) { Division.new.call(2, 2) }
    ensure
      BCDD::Result.config.transitions.listener = original_listener
    end
  end
end
