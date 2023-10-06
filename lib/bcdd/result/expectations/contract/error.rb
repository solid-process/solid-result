# frozen_string_literal: true

module BCDD::Result::Expectations::Contract
  module Error
    class UnexpectedType < ::BCDD::Result::Error
      def self.build(type:, allowed_types:)
        new("type :#{type} is not allowed. Allowed types: #{allowed_types.map(&:inspect).join(', ')}")
      end
    end

    class UnexpectedValue < ::BCDD::Result::Error
      def self.build(type:, value:)
        new("value #{value.inspect} is not allowed for :#{type} type")
      end
    end
  end
end
