# frozen_string_literal: true

require 'test_helper'

module BCDD::Result::Transitions
  class ListenersTest < Minitest::Test
    include BCDDResultTransitionAssertions

    module AroundListener
      extend BCDD::Result::Transitions::Listener

      def self.around_and_then?
        true
      end

      def self.around_transitions?
        true
      end

      class << self
        attr_reader :memo

        def new
          tap { @memo = Hash.new { |hash, key| hash[key] = [] } }
        end

        def around_transitions(scope:)
          memo[:around_transitions] << scope

          yield
        end

        def around_and_then(scope:, and_then:)
          memo[:around_and_then] << { scope: scope, and_then: and_then }

          yield
        end
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

    test 'one listener (without interruption)' do
      original_listener = BCDD::Result.config.transitions.listener

      BCDD::Result.config.transitions.listener = Listeners[InspectListener]

      result = Division.new.call(10, 2)

      scope = { id: 0, name: 'Division', desc: nil }

      assert_equal([scope], InspectListener.memo[:on_start])

      result.transitions[:records].each_with_index do |record, index|
        assert_equal(record, InspectListener.memo[:on_record][index])
      end

      assert_equal(result.transitions, InspectListener.memo[:on_finish].first)
    ensure
      BCDD::Result.config.transitions.listener = original_listener
    end

    test 'multiple listeners' do
      original_listener = BCDD::Result.config.transitions.listener

      BCDD::Result.config.transitions.listener = Listeners[InspectListener, AroundListener]

      result = Division.new.call(10, 2)

      scope = { id: 0, name: 'Division', desc: nil }

      assert_equal([scope], InspectListener.memo[:on_start])

      assert_empty(InspectListener.memo[:around_transitions])
      assert_empty(InspectListener.memo[:around_and_then])

      assert_equal([scope], AroundListener.memo[:around_transitions])

      [
        { scope: scope, and_then: { type: :method, arg: nil, method_name: :require_numbers } },
        { scope: scope, and_then: { type: :method, arg: nil, method_name: :check_for_zeros } },
        { scope: scope, and_then: { type: :method, arg: nil, method_name: :divide } }
      ].each_with_index do |and_then, index|
        assert_equal(and_then, AroundListener.memo[:around_and_then][index])
      end

      result.transitions[:records].each_with_index do |record, index|
        assert_equal(record, InspectListener.memo[:on_record][index])
      end

      assert_equal(result.transitions, InspectListener.memo[:on_finish].first)
    ensure
      BCDD::Result.config.transitions.listener = original_listener
    end

    test 'multiple listeners (with interruption)' do
      original_listener = BCDD::Result.config.transitions.listener

      BCDD::Result.config.transitions.listener = Listeners[InspectListener, AroundListener]

      assert_raises(ZeroDivisionError, 'divided by 0') { Division.new.call(10, 0) }

      on_record = InspectListener.memo[:on_record]

      before_interruption = InspectListener.memo[:before_interruption].first

      assert_transitions!(before_interruption[:transitions], size: 3)

      assert_equal(on_record, before_interruption[:transitions][:records])
    ensure
      BCDD::Result.config.transitions.listener = original_listener
    end

    module AroundAndThenListener
      extend BCDD::Result::Transitions::Listener

      def self.around_and_then?
        true
      end
    end

    test 'multiple around_and_then? listeners' do
      original_listener = BCDD::Result.config.transitions.listener

      assert_raises ArgumentError, 'Only one listener can have around_and_then? == true' do
        Listeners[
          AroundAndThenListener,
          InspectListener,
          AroundListener
        ]
      end
    ensure
      BCDD::Result.config.transitions.listener = original_listener
    end

    module AroundTransitionsListener
      extend BCDD::Result::Transitions::Listener

      def self.around_transitions?
        true
      end
    end

    test 'multiple around_transitions? listeners' do
      original_listener = BCDD::Result.config.transitions.listener

      assert_raises ArgumentError, 'only one listener can have around_transitions? == true' do
        Listeners[
          AroundListener,
          InspectListener,
          AroundTransitionsListener
        ]
      end
    ensure
      BCDD::Result.config.transitions.listener = original_listener
    end

    test 'invalid argument (empty)' do
      original_listener = BCDD::Result.config.transitions.listener

      assert_raises ArgumentError, 'listeners must be a list of BCDD::Result::Transitions::Listener' do
        Listeners[]
      end
    ensure
      BCDD::Result.config.transitions.listener = original_listener
    end

    test 'invalid argument (non Listener)' do
      original_listener = BCDD::Result.config.transitions.listener

      assert_raises ArgumentError, 'listeners must be a list of BCDD::Result::Transitions::Listener' do
        Listeners[String]
      end
    ensure
      BCDD::Result.config.transitions.listener = original_listener
    end
  end
end
