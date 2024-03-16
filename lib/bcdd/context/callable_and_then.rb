# frozen_string_literal: true

module BCDD
  module Context::CallableAndThen
    class Caller < Result::CallableAndThen::Caller
      module KeyArgs
        def self.parameters?(source)
          parameters = source.parameters.map(&:first)

          !parameters.empty? && parameters.all?(/\Akey/)
        end

        def self.invalid_arity(source, method)
          Result::CallableAndThen::Error::InvalidArity.build(source: source, method: method, arity: 'only keyword args')
        end
      end

      def self.call_proc!(source, value, _injected_value)
        return source.call(**value) if KeyArgs.parameters?(source)

        raise KeyArgs.invalid_arity(source, :call)
      end

      def self.call_method!(source, method, value, _injected_value)
        return source.send(method.name, **value) if KeyArgs.parameters?(method)

        raise KeyArgs.invalid_arity(source, method.name)
      end

      def self.ensure_result_object(source, value, result)
        return result.tap { result.send(:acc).then { _1.merge!(value.merge(_1)) } } if result.is_a?(Context)

        raise Result::Error::UnexpectedOutcome.build(outcome: result, origin: source,
                                                     expected: Context::EXPECTED_OUTCOME)
      end

      private_class_method :call_proc!, :call_method!
    end
  end
end
