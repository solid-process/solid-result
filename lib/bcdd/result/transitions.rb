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
end
