# frozen_string_literal: true

module BCDD::Result::EventLogs
  class Listeners
    class Chain
      include Listener

      attr_reader :listeners

      def initialize(list)
        if list.empty? || list.any? { !Listener.kind?(_1) }
          raise ArgumentError, "listeners must be a list of #{Listener}"
        end

        around_and_then = list.select(&:around_and_then?)
        around_event_logs = list.select(&:around_event_logs?)

        raise ArgumentError, 'only one listener can have around_and_then? == true' if around_and_then.size > 1
        raise ArgumentError, 'only one listener can have around_event_logs? == true' if around_event_logs.size > 1

        @listeners = { list: list, around_and_then: around_and_then[0], around_event_logs: around_event_logs[0] }
      end

      def new
        list, around_and_then, around_event_logs = listeners[:list], nil, nil

        instances = list.map do |item|
          instance = item.new
          around_and_then = instance if listener?(:around_and_then, instance)
          around_event_logs = instance if listener?(:around_event_logs, instance)

          instance
        end

        list.one? ? list[0].new : Listeners.send(:new, instances, around_and_then, around_event_logs)
      end

      private

      def listener?(name, obj)
        listener = listeners[name]

        !listener.nil? && (obj.is_a?(listener) || obj == listener)
      end
    end

    private_class_method :new

    def self.[](*listeners)
      Chain.new(listeners)
    end

    attr_reader :listeners, :around_and_then_listener, :around_event_logs_listener

    private :listeners, :around_and_then_listener, :around_event_logs_listener

    def initialize(listeners, around_and_then_listener, around_event_logs_listener)
      @listeners = listeners
      @around_and_then_listener = around_and_then_listener || Listener::Null
      @around_event_logs_listener = around_event_logs_listener || Listener::Null
    end

    def on_start(scope:)
      listeners.each { _1.on_start(scope: scope) }
    end

    def around_event_logs(scope:, &block)
      around_event_logs_listener.around_event_logs(scope: scope, &block)
    end

    def around_and_then(scope:, and_then:, &block)
      around_and_then_listener.around_and_then(scope: scope, and_then: and_then, &block)
    end

    def on_record(record:)
      listeners.each { _1.on_record(record: record) }
    end

    def on_finish(event_logs:)
      listeners.each { _1.on_finish(event_logs: event_logs) }
    end

    def before_interruption(exception:, event_logs:)
      listeners.each { _1.before_interruption(exception: exception, event_logs: event_logs) }
    end
  end
end
