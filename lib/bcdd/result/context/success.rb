# frozen_string_literal: true

class BCDD::Result
  class Context::Error < BCDD::Result::Error
    InvalidExposure = ::Class.new(self)
  end

  class Context::Success < Context
    include ::BCDD::Result::Success::Methods

    FetchValues = ->(acc_values, keys) do
      fetched_values = acc_values.fetch_values(*keys)

      keys.zip(fetched_values).to_h
    rescue ::KeyError => e
      message = "#{e.message}. Available to expose: #{acc_values.keys.map(&:inspect).join(', ')}"

      raise Context::Error::InvalidExposure, message
    end

    def and_expose(type, keys, terminal: true)
      unless keys.is_a?(::Array) && !keys.empty? && keys.all?(::Symbol)
        raise ::ArgumentError, 'keys must be an Array of Symbols'
      end

      Transitions.tracking.reset_and_then!

      acc_values = acc.merge(value)

      value_to_expose = FetchValues.call(acc_values, keys)

      expectations = type_checker.expectations

      self.class.new(type: type, value: value_to_expose, source: source, terminal: terminal, expectations: expectations)
    end
  end
end
