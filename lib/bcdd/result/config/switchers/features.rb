# frozen_string_literal: true

class BCDD::Result
  class Config
    module Features
      OPTIONS = {
        expectations: {
          default: true,
          affects: %w[BCDD::Result::Expectations BCDD::Result::Context::Expectations]
        }
      }.transform_values!(&:freeze).freeze

      def self.switcher
        Switcher.new(options: OPTIONS)
      end
    end

    private_constant :Features
  end
end
