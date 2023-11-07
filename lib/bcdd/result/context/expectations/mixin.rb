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

      def self.options(names)
        ::BCDD::Result::Config::Options.filter(names, OPTIONS)
      end
    end
  end
end
