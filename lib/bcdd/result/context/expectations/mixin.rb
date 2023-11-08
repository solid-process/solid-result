# frozen_string_literal: true

class BCDD::Result::Context
  module Expectations::Mixin
    Factory = BCDD::Result::Expectations::Mixin::Factory

    METHODS = BCDD::Result::Expectations::Mixin::METHODS

    module Addons
      module Continuable
        private def Continue(**value)
          Success.new(type: :continued, value: value, subject: self)
        end
      end

      OPTIONS = { continue: Continuable }.freeze

      def self.options(config_flags)
        ::BCDD::Result::Config::Options.unwrap(options: { addon: OPTIONS }, flags: config_flags)
      end
    end
  end
end
