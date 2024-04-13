# frozen_string_literal: true

class Solid::Result
  class Config
    module Addons
      AFFECTS = %w[
        Solid::Result.mixin
        Solid::Output.mixin
        Solid::Result::Expectations.mixin
        Solid::Output::Expectations.mixin
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
