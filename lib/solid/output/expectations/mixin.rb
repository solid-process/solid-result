# frozen_string_literal: true

class Solid::Output
  module Expectations::Mixin
    Factory = Solid::Result::Expectations::Mixin::Factory

    Methods = Solid::Result::Expectations::Mixin::Methods

    module Addons
      module Continue
        private def Continue(**value)
          Success(::Solid::Result::IgnoredTypes::CONTINUE, **value)
        end
      end

      module Given
        private def Given(*values)
          value = values.map(&:to_h).reduce({}) { |acc, val| acc.merge(val) }

          Success(::Solid::Result::IgnoredTypes::GIVEN, **value)
        end
      end

      OPTIONS = { continue: Continue, given: Given }.freeze

      def self.options(config_flags)
        ::Solid::Result::Config::Options.addon(map: config_flags, from: OPTIONS)
      end
    end
  end
end
