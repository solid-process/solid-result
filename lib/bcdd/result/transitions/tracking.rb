# frozen_string_literal: true

class BCDD::Result
  module Transitions
    module Tracking
      require_relative 'tracking/enabled'
      require_relative 'tracking/disabled'

      def self.instance
        Config.instance.feature.enabled?(:transitions) ? Tracking::Enabled.new : Tracking::Disabled
      end
    end
  end
end
