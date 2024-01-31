# frozen_string_literal: true

class BCDD::Result::Context
  module Expectations::Mixin
    Factory = BCDD::Result::Expectations::Mixin::Factory

    Methods = BCDD::Result::Expectations::Mixin::Methods

    module Addons
      module Continue
        private def Continue(**value)
          Success(::BCDD::Result::IgnoredTypes::CONTINUE, **value)
        end
      end

      module Given
        private def Given(*values)
          value = values.map(&:to_h).reduce({}) { |acc, val| acc.merge(val) }

          Success(::BCDD::Result::IgnoredTypes::GIVEN, **value)
        end
      end

      OPTIONS = { continue: Continue, given: Given }.freeze

      def self.options(config_flags)
        ::BCDD::Result::Config::Options.addon(map: config_flags, from: OPTIONS)
      end
    end
  end
end
