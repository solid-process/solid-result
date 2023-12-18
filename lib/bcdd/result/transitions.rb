# frozen_string_literal: true

require 'securerandom'

class BCDD::Result
  module Transitions
    class Monitor
      attr_accessor :started, :tracked, :root_id

      def started?
        started
      end

      def start!(id:)
        return if started?

        self.started = true
        self.tracked = []
        self.root_id = id
      end

      def reset!
        self.started = nil
        self.tracked = nil
        self.root_id = nil
      end

      def root_id?(id)
        root_id == id
      end

      def track(result)
        track!(result)
      end

      private

      def track!(result)
        tracked << { root_id: root_id, data: result.data }
      end
    end

    def self.monitor
      Thread.current[:bcdd_result_transitions_monitor] ||= Monitor.new
    end
  end

  # rubocop:disable Metrics/MethodLength
  def self.transitions(id: SecureRandom.uuid)
    Transitions.monitor.start!(id: id)

    result = yield

    unless result.is_a?(::BCDD::Result)
      Transitions.monitor.reset!

      raise Error::UnexpectedOutcome.build(outcome: result, origin: :transitions)
    end

    if Transitions.monitor.root_id?(id)
      result.send(:transitions=, Transitions.monitor.tracked)

      Transitions.monitor.reset!
    end

    result
  end
  # rubocop:enable Metrics/MethodLength
end
