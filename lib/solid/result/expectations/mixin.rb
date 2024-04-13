# frozen_string_literal: true

class Solid::Result
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
          @_Result ||= Result.with(source: self, terminal: %<terminal>s)
        end
      RUBY

      def self.to_eval(addons)
        terminal = addons.key?(:continue) ? 'true' : 'nil'

        "#{BASE}\n#{format(FACTORY, terminal: terminal)}"
      end
    end

    module Addons
      module Continue
        private def Continue(value)
          _Result.Success(IgnoredTypes::CONTINUE, value)
        end
      end

      module Given
        private def Given(value)
          _Result.Success(IgnoredTypes::GIVEN, value)
        end
      end

      OPTIONS = { continue: Continue, given: Given }.freeze

      def self.options(config_flags)
        Config::Options.addon(map: config_flags, from: OPTIONS)
      end
    end
  end
end
