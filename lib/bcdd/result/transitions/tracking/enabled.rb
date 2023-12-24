# frozen_string_literal: true

class BCDD::Result
  module Transitions::Tracking
    class Enabled
      attr_accessor :started, :records, :root, :current, :current_and_then

      private :started, :started=, :records, :records=, :root, :root=
      private :current, :current=, :current_and_then, :current_and_then=

      def start(id:, name:, desc:)
        self.current = { id: id, name: name, desc: desc }

        return if started

        self.root = current
        self.started = true

        reset_records!
        reset_current_and_then!
      end

      def finish(id:, result:)
        return if root && root[:id] != id

        result.send(:transitions=, records)

        reset!
      end

      def reset!
        self.root = nil
        self.current = nil
        self.started = nil

        reset_records!
        reset_current_and_then!
      end

      def record(result)
        return unless started

        add(result, time: ::Time.now.getutc)

        reset_current_and_then!
      end

      def record_and_then(type_arg, arg, subject)
        type = type_arg.instance_of?(::Method) ? :method : type_arg

        self.current_and_then = { type: type, arg: arg, subject: subject }

        current_and_then[:method_name] = type_arg.name if type == :method

        yield
      end

      private

      def add(result, time:)
        data = result.data.to_h

        records << { root: root, current: current, result: data, and_then: current_and_then, time: time, version: 1 }
      end

      def reset_records!
        self.records = []
      end

      EMPTY_HASH = {}.freeze

      def reset_current_and_then!
        self.current_and_then = EMPTY_HASH
      end
    end
  end
end
