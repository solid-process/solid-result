# frozen_string_literal: true

class BCDD::Result
  module EventLogs
    require_relative 'event_logs/listener'
    require_relative 'event_logs/listeners'
    require_relative 'event_logs/config'
    require_relative 'event_logs/tree'
    require_relative 'event_logs/tracking'

    THREAD_VAR_NAME = :bcdd_result_event_logs_tracking

    EnsureResult = ->(result) do
      return result if result.is_a?(::BCDD::Result)

      raise Error::UnexpectedOutcome.build(outcome: result, origin: :event_logs)
    end

    def self.tracking
      Thread.current[THREAD_VAR_NAME] ||= Tracking.instance
    end
  end

  def self.event_logs(name: nil, desc: nil, &block)
    EventLogs.tracking.exec(name, desc, &block)
  end
end
