# frozen_string_literal: true

module BCDD::Result::Expectations::Contract
  module Error
    class UnexpectedType < ::BCDD::Result::Error
      def self.build(type:, allowed_types:)
        new("type :#{type} is not allowed. Allowed types: #{allowed_types.map(&:inspect).join(', ')}")
      end
    end

    class UnexpectedValue < ::BCDD::Result::Error
      def self.build(type:, value:, allowed_value:)
        new("data #{value.inspect} is not allowed for type :#{type}. Allowed data: #{allowed_value.inspect}")
      end
    end
  end
end
