# frozen_string_literal: true

module BCDD::Result::Transitions
  module Tracking
    class Enabled
      attr_accessor :started, :records, :root_id

      private :started, :started=, :root_id, :root_id=, :records, :records=

      def start(id:)
        return if started

        self.started = true
        self.root_id = id
        self.records = []
      end

      def finish(id:, result:)
        return unless root_id?(id)

        result.send(:transitions=, records)

        reset!
      end

      def reset!
        self.started = nil
        self.root_id = nil
        self.records = []
      end

      def record(result)
        add(result) if started
      end

      private

      def root_id?(id)
        root_id == id
      end

      def add(result)
        records << { root_id: root_id, data: result.data }
      end
    end
  end
end
