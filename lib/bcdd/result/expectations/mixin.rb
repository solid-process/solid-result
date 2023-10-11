# frozen_string_literal: true

class BCDD::Result::Expectations
  module Mixin
    METHODS = <<~RUBY
      def Success(...)
        __expected::Success(...)
      end

      def Failure(...)
        __expected::Failure(...)
      end

      private

      def __expected
        @__expected ||= Expected.with(subject: self)
      end
    RUBY

    module Addons
      module Continuable
        private def Continue(value)
          ::BCDD::Result::Success.new(type: :continued, value: value, subject: self)
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
