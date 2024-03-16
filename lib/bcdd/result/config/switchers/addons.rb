# frozen_string_literal: true

class BCDD::Result
  class Config
    module Addons
      AFFECTS = %w[
        BCDD::Result.mixin
        BCDD::Context.mixin
        BCDD::Result::Expectations.mixin
        BCDD::Context::Expectations.mixin
      ].freeze

      OPTIONS = {
        continue: { default: false, affects: AFFECTS },
        given: { default: true, affects: AFFECTS }
      }.transform_values!(&:freeze).freeze

      def self.switcher
        Switcher.new(options: OPTIONS)
      end
    end

    private_constant :Addons
  end
end
