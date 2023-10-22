# frozen_string_literal: true

class BCDD::Result
  class Context::Success < Context
    include Success::Methods

    def and_expose(type, keys)
      unless keys.is_a?(Array) && !keys.empty? && keys.all?(Symbol)
        raise ::ArgumentError, 'keys must be an Array of Symbols'
      end

      exposed_value = acc.merge(value).slice(*keys)

      self.class.new(type: type, value: exposed_value, subject: subject, acc: acc)
    end
  end
end
