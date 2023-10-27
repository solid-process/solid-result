# frozen_string_literal: true

class BCDD::Result::Contract::Error < BCDD::Result::Error
  class UnexpectedType < self
    def self.build(type:, allowed_types:)
      new("type :#{type} is not allowed. Allowed types: #{allowed_types.map(&:inspect).join(', ')}")
    end
  end

  class UnexpectedValue < self
    def self.build(type:, value:, cause: nil)
      cause_message = " (#{cause.message})" if cause

      new("value #{value.inspect} is not allowed for :#{type} type#{cause_message}")
    end
  end
end
