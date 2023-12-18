# frozen_string_literal: true

require 'securerandom'

class BCDD::Result
  module Transitions
    class Tracking
      attr_accessor :started, :records, :root_id

      private :started=, :root_id, :root_id=, :records=

      def start!(id:)
        return if started

        self.started = true
        self.records = []
        self.root_id = id
      end

      def reset!
        self.started = nil
        self.records = nil
        self.root_id = nil
      end

      def root_id?(id)
        root_id == id
      end

      def add(result)
        records << { root_id: root_id, data: result.data }
      end
    end

    def self.tracking
      Thread.current[:bcdd_result_transitions_tracking] ||= Tracking.new
    end

    def self.track(result)
      tracking.add(result) if tracking.started
    end

    def self.start(id:)
      tracking.start!(id: id)
    end

    def self.finish(id:, result:)
      unless result.is_a?(::BCDD::Result)
        tracking.reset!

        raise Error::UnexpectedOutcome.build(outcome: result, origin: :transitions)
      end

      return unless tracking.root_id?(id)

      result.send(:transitions=, tracking.records)

      tracking.reset!
    end
  end

  def self.transitions(id: SecureRandom.uuid)
    Transitions.start(id: id)

    result = yield

    Transitions.finish(id: id, result: result)

    result
  end
end
