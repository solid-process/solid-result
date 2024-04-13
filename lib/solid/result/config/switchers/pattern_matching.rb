# frozen_string_literal: true

class Solid::Result
  class Config
    module PatternMatching
      OPTIONS = {
        nil_as_valid_value_checking: {
          default: false,
          affects: %w[Solid::Result::Expectations Solid::Output::Expectations]
        }
      }.transform_values!(&:freeze).freeze

      def self.switcher
        Switcher.new(options: OPTIONS)
      end
    end

    private_constant :PatternMatching
  end
end
