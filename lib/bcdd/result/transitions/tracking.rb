# frozen_string_literal: true

class BCDD::Result
  module Transitions
    module Tracking
      require_relative 'tracking/enabled'
      require_relative 'tracking/disabled'

      EMPTY_HASH = {}.freeze
      EMPTY_ARRAY = [].freeze
      VERSION = 1
      EMPTY = { records: EMPTY_ARRAY, version: VERSION }.freeze

      def self.instance
        Config.instance.feature.enabled?(:transitions) ? Tracking::Enabled.new : Tracking::Disabled
      end
    end
  end
end
