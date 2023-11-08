# frozen_string_literal: true

class BCDD::Result
  module Expectations::Mixin
    module Factory
      def self.module!
        ::Module.new do
          def self.included(base); base.const_set(:ResultExpectationsMixin, self); end
          def self.extended(base); base.const_set(:ResultExpectationsMixin, self); end
        end
      end
    end

    METHODS = <<~RUBY
      def Success(...)
        _Result.Success(...)
      end

      def Failure(...)
        _Result.Failure(...)
      end

      private

      def _Result
        @_Result ||= Result.with(subject: self)
      end
    RUBY

    module Addons
      module Continuable
        private def Continue(value)
          Success.new(type: :continued, value: value, subject: self)
        end
      end

      OPTIONS = { continue: Continuable }.freeze

      def self.options(config_flags)
        Config::Options.addon(map: config_flags, from: OPTIONS)
      end
    end
  end
end
