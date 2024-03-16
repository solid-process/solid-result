# frozen_string_literal: true

class BCDD::Result::EventLogsRecord < ActiveRecord::Base
  self.table_name = 'bcdd_result_event_logs'

  class Listener
    include ::BCDD::Result::EventLogs::Listener

    def on_finish(event_logs:)
        metadata = event_logs[:metadata]
        root_name = event_logs.dig(:records, 0, :root, :name) || 'Unknown'

        BCDD::Result::EventLogsRecord.create(
          root_name: root_name,
          trace_id: metadata[:trace_id],
          version: event_logs[:version],
          duration: metadata[:duration],
          ids: metadata[:ids],
          records: event_logs[:records]
        )
    rescue ::StandardError => e
      err = "#{e.message} (#{e.class}); Backtrace: #{e.backtrace.join(', ')}"

      ::Kernel.warn "Error on BCDD::Result::EventLogsRecord::Listener#on_finish: #{err}"
    end
  end
end
