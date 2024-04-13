# frozen_string_literal: true

require 'test_helper'

module Solid::Result::EventLogs
  class ListenersTest < Minitest::Test
    include SolidResultEventLogAssertions

    module AroundListener
      extend Solid::Result::EventLogs::Listener

      def self.around_and_then?
        true
      end

      def self.around_event_logs?
        true
      end

      class << self
        attr_reader :memo

        def new
          tap { @memo = Hash.new { |hash, key| hash[key] = [] } }
        end

        def around_event_logs(scope:)
          memo[:around_event_logs] << scope

          yield
        end

        def around_and_then(scope:, and_then:)
          memo[:around_and_then] << { scope: scope, and_then: and_then }

          yield
        end
      end
    end

    module InspectListener
      extend Solid::Result::EventLogs::Listener

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

        def on_finish(event_logs:)
          memo[:on_finish] << event_logs
        end

        def before_interruption(exception:, event_logs:)
          memo[:before_interruption] << { exception: exception, event_logs: event_logs }
        end
      end
    end

    class Division
      include Solid::Result.mixin(config: { addon: { continue: true } })

      def call(arg1, arg2)
        Solid::Result.event_logs(name: 'Division') do
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
      original_listener = Solid::Result.config.event_logs.listener

      Solid::Result.config.event_logs.listener = Listeners[InspectListener]

      result = Division.new.call(10, 2)

      scope = { id: 0, name: 'Division', desc: nil }

      assert_equal([scope], InspectListener.memo[:on_start])

      result.event_logs[:records].each_with_index do |record, index|
        assert_equal(record, InspectListener.memo[:on_record][index])
      end

      assert_equal(result.event_logs, InspectListener.memo[:on_finish].first)
    ensure
      Solid::Result.config.event_logs.listener = original_listener
    end

    test 'multiple listeners' do
      original_listener = Solid::Result.config.event_logs.listener

      Solid::Result.config.event_logs.listener = Listeners[InspectListener, AroundListener]

      result = Division.new.call(10, 2)

      scope = { id: 0, name: 'Division', desc: nil }

      assert_equal([scope], InspectListener.memo[:on_start])

      assert_empty(InspectListener.memo[:around_event_logs])
      assert_empty(InspectListener.memo[:around_and_then])

      assert_equal([scope], AroundListener.memo[:around_event_logs])

      [
        { scope: scope, and_then: { type: :method, arg: nil, method_name: :require_numbers } },
        { scope: scope, and_then: { type: :method, arg: nil, method_name: :check_for_zeros } },
        { scope: scope, and_then: { type: :method, arg: nil, method_name: :divide } }
      ].each_with_index do |and_then, index|
        assert_equal(and_then, AroundListener.memo[:around_and_then][index])
      end

      result.event_logs[:records].each_with_index do |record, index|
        assert_equal(record, InspectListener.memo[:on_record][index])
      end

      assert_equal(result.event_logs, InspectListener.memo[:on_finish].first)
    ensure
      Solid::Result.config.event_logs.listener = original_listener
    end

    test 'multiple listeners (with interruption)' do
      original_listener = Solid::Result.config.event_logs.listener

      Solid::Result.config.event_logs.listener = Listeners[InspectListener, AroundListener]

      assert_raises(ZeroDivisionError, 'divided by 0') { Division.new.call(10, 0) }

      on_record = InspectListener.memo[:on_record]

      before_interruption = InspectListener.memo[:before_interruption].first

      assert_event_logs!(before_interruption[:event_logs], size: 3)

      assert_equal(on_record, before_interruption[:event_logs][:records])
    ensure
      Solid::Result.config.event_logs.listener = original_listener
    end

    module AroundAndThenListener
      extend Solid::Result::EventLogs::Listener

      def self.around_and_then?
        true
      end
    end

    test 'multiple around_and_then? listeners' do
      original_listener = Solid::Result.config.event_logs.listener

      assert_raises ArgumentError, 'Only one listener can have around_and_then? == true' do
        Listeners[
          AroundAndThenListener,
          InspectListener,
          AroundListener
        ]
      end
    ensure
      Solid::Result.config.event_logs.listener = original_listener
    end

    module AroundEventLogsListener
      extend Solid::Result::EventLogs::Listener

      def self.around_event_logs?
        true
      end
    end

    test 'multiple around_event_logs? listeners' do
      original_listener = Solid::Result.config.event_logs.listener

      assert_raises ArgumentError, 'only one listener can have around_event_logs? == true' do
        Listeners[
          AroundListener,
          InspectListener,
          AroundEventLogsListener
        ]
      end
    ensure
      Solid::Result.config.event_logs.listener = original_listener
    end

    test 'invalid argument (empty)' do
      original_listener = Solid::Result.config.event_logs.listener

      assert_raises ArgumentError, 'listeners must be a list of Solid::Result::EventLogs::Listener' do
        Listeners[]
      end
    ensure
      Solid::Result.config.event_logs.listener = original_listener
    end

    test 'invalid argument (non Listener)' do
      original_listener = Solid::Result.config.event_logs.listener

      assert_raises ArgumentError, 'listeners must be a list of Solid::Result::EventLogs::Listener' do
        Listeners[String]
      end
    ensure
      Solid::Result.config.event_logs.listener = original_listener
    end
  end
end
