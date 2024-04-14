# frozen_string_literal: true

class Solid::Result
  module EventLogs
    module Tracking
      require_relative 'tracking/enabled'
      require_relative 'tracking/disabled'

      VERSION = 1

      EMPTY_ARRAY = [].freeze
      EMPTY_HASH = {}.freeze
      EMPTY_TREE = Tree.new(nil).freeze
      EMPTY_IDS = { tree: EMPTY_ARRAY, matrix: EMPTY_HASH, level_parent: EMPTY_HASH }.freeze
      EMPTY = {
        version: VERSION,
        records: EMPTY_ARRAY,
        metadata: { duration: 0, ids: EMPTY_IDS, trace_id: nil }.freeze
      }.freeze

      def self.instance
        ::Solid::Result::Config.instance.feature.enabled?(:event_logs) ? Tracking::Enabled.new : Tracking::Disabled
      end
    end
  end
end
