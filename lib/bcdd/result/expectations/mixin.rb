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

    module Methods
      BASE = <<~RUBY
        def Success(...)
          _Result.Success(...)
        end

        def Failure(...)
          _Result.Failure(...)
        end
      RUBY

      FACTORY = <<~RUBY
        private def _Result
          @_Result ||= Result.with(subject: self, halted: %<halted>s)
        end
      RUBY

      def self.to_eval(addons)
        halted = addons.key?(:continue) ? 'true' : 'nil'

        "#{BASE}\n#{format(FACTORY, halted: halted)}"
      end
    end

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
