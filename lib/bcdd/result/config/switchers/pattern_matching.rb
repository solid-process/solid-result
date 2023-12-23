# frozen_string_literal: true

class BCDD::Result
  class Config
    module PatternMatching
      OPTIONS = {
        nil_as_valid_value_checking: {
          default: false,
          affects: %w[BCDD::Result::Expectations BCDD::Result::Context::Expectations]
        }
      }.transform_values!(&:freeze).freeze

      def self.switcher
        Switcher.new(options: OPTIONS)
      end
    end

    private_constant :PatternMatching
  end
end
