# frozen_string_literal: true

class BCDD::Result
  module Transitions
    module Tracking
      require_relative 'tracking/enabled'
      require_relative 'tracking/disabled'

      EMPTY_ARRAY = [].freeze
      EMPTY_HASH = {}.freeze
      EMPTY_TREE = Tree.new(nil).freeze
      VERSION = 1
      EMPTY = { version: VERSION, records: EMPTY_ARRAY, metadata: { duration: 0, tree_map: EMPTY_ARRAY } }.freeze

      def self.instance
        Config.instance.feature.enabled?(:transitions) ? Tracking::Enabled.new : Tracking::Disabled
      end
    end
  end
end
