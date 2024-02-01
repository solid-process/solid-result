# frozen_string_literal: true

class BCDD::Result::TransitionsRecord < ActiveRecord::Base
  self.table_name = 'bcdd_result_transitions'

  class Listener
    include ::BCDD::Result::Transitions::Listener

    def on_finish(transitions:)
        metadata = transitions[:metadata]
        root_name = transitions.dig(:records, 0, :root, :name) || 'Unknown'

        BCDD::Result::TransitionsRecord.create(
          root_name: root_name,
          trace_id: metadata[:trace_id],
          version: transitions[:version],
          duration: metadata[:duration],
          ids_tree: metadata[:ids_tree],
          ids_matrix: metadata[:ids_matrix],
          records: transitions[:records]
        )
    rescue ::StandardError => e
      err = "#{e.message} (#{e.class}); Backtrace: #{e.backtrace.join(', ')}"

      ::Kernel.warn "Error on BCDD::Result::TransitionsRecord::Listener#on_finish: #{err}"
    end
  end
end
