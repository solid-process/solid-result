# frozen_string_literal: true

class Solid::Output
  class Error < Solid::Result::Error
    InvalidExposure = ::Class.new(self)
  end

  class Success < self
    include ::Solid::Success

    FetchValues = ->(memo_values, keys) do
      fetched_values = memo_values.fetch_values(*keys)

      keys.zip(fetched_values).to_h
    rescue ::KeyError => e
      message = "#{e.message}. Available to expose: #{memo_values.keys.map(&:inspect).join(', ')}"

      raise Error::InvalidExposure, message
    end

    def and_expose(type, keys, terminal: true)
      unless keys.is_a?(::Array) && !keys.empty? && keys.all?(::Symbol)
        raise ::ArgumentError, 'keys must be an Array of Symbols'
      end

      EventLogs.tracking.reset_and_then!

      memo_values = memo.merge(value)

      value_to_expose = FetchValues.call(memo_values, keys)

      expectations = type_checker.expectations

      self.class.new(type: type, value: value_to_expose, source: source, terminal: terminal, expectations: expectations)
    end
  end
end
