# frozen_string_literal: true

module BCDD::Result::Transitions
  class Listeners
    class Chain
      include Listener

      attr_reader :listeners

      def initialize(list)
        if list.empty? || list.any? { !Listener.kind?(_1) }
          raise ArgumentError, "listeners must be a list of #{Listener}"
        end

        around_and_then = list.select(&:around_and_then?)
        around_transitions = list.select(&:around_transitions?)

        raise ArgumentError, 'only one listener can have around_and_then? == true' if around_and_then.size > 1
        raise ArgumentError, 'only one listener can have around_transitions? == true' if around_transitions.size > 1

        @listeners = { list: list, around_and_then: around_and_then[0], around_transitions: around_transitions[0] }
      end

      def new
        list, around_and_then, around_transitions = listeners[:list], nil, nil

        instances = list.map do |item|
          instance = item.new
          around_and_then = instance if listener?(:around_and_then, instance)
          around_transitions = instance if listener?(:around_transitions, instance)

          instance
        end

        list.one? ? list[0].new : Listeners.send(:new, instances, around_and_then, around_transitions)
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

    attr_reader :listeners, :around_and_then_listener, :around_transitions_listener

    private :listeners, :around_and_then_listener, :around_transitions_listener

    def initialize(listeners, around_and_then_listener, around_transitions_listener)
      @listeners = listeners
      @around_and_then_listener = around_and_then_listener || Listener::Null
      @around_transitions_listener = around_transitions_listener || Listener::Null
    end

    def on_start(scope:)
      listeners.each { _1.on_start(scope: scope) }
    end

    def around_transitions(scope:, &block)
      around_transitions_listener.around_transitions(scope: scope, &block)
    end

    def around_and_then(scope:, and_then:, &block)
      around_and_then_listener.around_and_then(scope: scope, and_then: and_then, &block)
    end

    def on_record(record:)
      listeners.each { _1.on_record(record: record) }
    end

    def on_finish(transitions:)
      listeners.each { _1.on_finish(transitions: transitions) }
    end

    def before_interruption(exception:, transitions:)
      listeners.each { _1.before_interruption(exception: exception, transitions: transitions) }
    end
  end
end
