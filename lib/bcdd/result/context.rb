# frozen_string_literal: true

class BCDD::Result
  class Context < self
    require_relative 'context/failure'
    require_relative 'context/success'
    require_relative 'context/mixin'
    require_relative 'context/expectations'

    def self.Success(type, **value)
      Success.new(type: type, value: value)
    end

    def self.Failure(type, **value)
      Failure.new(type: type, value: value)
    end

    def initialize(type:, value:, source: nil, expectations: nil, terminal: nil)
      value.is_a?(::Hash) or raise ::ArgumentError, 'value must be a Hash'

      @acc = {}

      super
    end

    def and_then(method_name = nil, **injected_value, &block)
      super(method_name, injected_value, &block)
    end

    protected

    attr_reader :acc

    private

    SourceMethodArity = ->(method) do
      return 0 if method.arity.zero?
      return 1 if method.parameters.map(&:first).all?(/\Akey/)

      -1
    end

    def call_and_then_source_method!(method, injected_value)
      acc.merge!(value.merge(injected_value))

      case SourceMethodArity[method]
      when 0 then source.send(method.name)
      when 1 then source.send(method.name, **acc)
      else raise Error::InvalidSourceMethodArity.build(source: source, method: method, max_arity: 1)
      end
    end

    def call_and_then_block!(block)
      acc.merge!(value)

      block.call(acc)
    end

    def ensure_result_object(result, origin:)
      raise_unexpected_outcome_error(result, origin) unless result.is_a?(Context)

      return result.tap { _1.acc.merge!(acc) } if result.source.equal?(source)

      raise Error::InvalidResultSource.build(given_result: result, expected_source: source)
    end

    EXPECTED_OUTCOME = 'BCDD::Result::Context::Success or BCDD::Result::Context::Failure'

    def raise_unexpected_outcome_error(result, origin)
      raise Error::UnexpectedOutcome.build(outcome: result, origin: origin, expected: EXPECTED_OUTCOME)
    end

    private_constant :SourceMethodArity, :EXPECTED_OUTCOME
  end
end
