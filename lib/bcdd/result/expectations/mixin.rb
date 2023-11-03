# frozen_string_literal: true

class BCDD::Result
  module Expectations::Mixin
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
          Success.new(type: BCDD::Result::CONTINUED, value: value, subject: self)
        end
      end

      OPTIONS = { Continue: Continuable }.freeze

      def self.options(names)
        Array(names).filter_map { |name| OPTIONS[name] }
      end
    end

    def self.module!
      ::Module.new do
        def self.included(base); base.const_set(:ResultExpectationsMixin, self); end
        def self.extended(base); base.const_set(:ResultExpectationsMixin, self); end
      end
    end
  end
end
