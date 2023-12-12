# frozen_string_literal: true

class BCDD::Result::Context::Success < BCDD::Result::Context
  include ::BCDD::Result::Success::Methods

  def and_expose(type, keys, halted: true)
    unless keys.is_a?(::Array) && !keys.empty? && keys.all?(::Symbol)
      raise ::ArgumentError, 'keys must be an Array of Symbols'
    end

    exposed_value = acc.merge(value).slice(*keys)

    self.class.new(type: type, value: exposed_value, subject: subject, halted: halted)
  end
end
