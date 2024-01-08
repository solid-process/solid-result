# frozen_string_literal: true

class BCDD::Result
  class CallableAndThen::Caller
    def self.call(source, value:, injected_value:, method_name:)
      method = callable_method(source, method_name)

      Transitions.tracking.record_and_then(method, injected_value, source) do
        result =
          if source.is_a?(::Proc)
            call_proc!(source, value, injected_value)
          else
            call_method!(source, method, value, injected_value)
          end

        ensure_result_object(source, value, result)
      end
    end

    def self.call_proc!(source, value, injected_value)
      case source.arity
      when 1 then source.call(value)
      when 2 then source.call(value, injected_value)
      else raise CallableAndThen::Error::InvalidArity.build(source: source, method: :call, arity: '1..2')
      end
    end

    def self.call_method!(source, method, value, injected_value)
      case method.arity
      when 1 then source.send(method.name, value)
      when 2 then source.send(method.name, value, injected_value)
      else raise CallableAndThen::Error::InvalidArity.build(source: source, method: method.name, arity: '1..2')
      end
    end

    def self.callable_method(source, method_name)
      source.method(method_name || Config.instance.and_then!.default_method_name_to_call)
    end

    def self.ensure_result_object(source, _value, result)
      return result if result.is_a?(::BCDD::Result)

      raise Error::UnexpectedOutcome.build(outcome: result, origin: source)
    end

    private_class_method :new, :allocate
    private_class_method :call_proc!, :call_method!, :callable_method, :ensure_result_object
  end
end
