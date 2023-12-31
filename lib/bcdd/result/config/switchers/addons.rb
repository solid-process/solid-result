# frozen_string_literal: true

class BCDD::Result
  class Config
    module Addons
      OPTIONS = {
        continue: {
          default: false,
          affects: %w[BCDD::Result BCDD::Result::Context BCDD::Result::Expectations BCDD::Result::Context::Expectations]
        }
      }.transform_values!(&:freeze).freeze

      def self.switcher
        Switcher.new(options: OPTIONS)
      end
    end

    private_constant :Addons
  end
end
