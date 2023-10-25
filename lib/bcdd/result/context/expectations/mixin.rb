# frozen_string_literal: true

class BCDD::Result::Context
  module Expectations::Mixin
    METHODS = <<~RUBY
      def Success(...)
        _Result::Success(...)
      end

      def Failure(...)
        _Result::Failure(...)
      end

      private

      def _Result
        @_Result ||= Result.with(subject: self)
      end
    RUBY

    module Addons
      module Continuable
        private def Continue(**value)
          Success.new(type: :continued, value: value, subject: self)
        end
      end

      OPTIONS = { Continue: Continuable }.freeze

      def self.options(names)
        Array(names).filter_map { |name| OPTIONS[name] }
      end
    end
  end

  private_constant :Mixin
end
