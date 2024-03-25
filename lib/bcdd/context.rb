# frozen_string_literal: true

class BCDD::Context < BCDD::Result
  require_relative 'context/failure'
  require_relative 'context/success'
  require_relative 'context/mixin'
  require_relative 'context/expectations'
  require_relative 'context/callable_and_then'

  EXPECTED_OUTCOME = 'BCDD::Context::Success or BCDD::Context::Failure'

  def self.Success(type, **value)
    Success.new(type: type, value: value)
  end

  def self.Failure(type, **value)
    Failure.new(type: type, value: value)
  end

  def initialize(type:, value:, source: nil, expectations: nil, terminal: nil)
    value.is_a?(::Hash) or raise ::ArgumentError, 'value must be a Hash'

    @memo = {}

    super
  end

  def and_then(method_name = nil, **injected_value, &block)
    super(method_name, injected_value, &block)
  end

  def and_then!(source, **injected_value)
    _call = injected_value.delete(:_call)

    memo.merge!(injected_value)

    super(source, injected_value, _call: _call)
  end

  protected

  attr_reader :memo

  private

  SourceMethodArity = ->(method) do
    return 0 if method.arity.zero?

    parameters = method.parameters.map(&:first)

    return 1 if !parameters.empty? && parameters.all?(/\Akey/)

    -1
  end

  def call_and_then_source_method!(method, injected_value)
    memo.merge!(value.merge(injected_value))

    case SourceMethodArity[method]
    when 0 then source.send(method.name)
    when 1 then source.send(method.name, **memo)
    else raise Error::InvalidSourceMethodArity.build(source: source, method: method, max_arity: 1)
    end
  end

  def call_and_then_block!(block)
    memo.merge!(value)

    block.call(memo)
  end

  def call_and_then_callable!(source, value:, injected_value:, method_name:)
    memo.merge!(value.merge(injected_value))

    CallableAndThen::Caller.call(source, value: memo, injected_value: injected_value, method_name: method_name)
  end

  def ensure_result_object(result, origin:)
    raise_unexpected_outcome_error(result, origin) unless result.is_a?(BCDD::Context)

    return result.tap { _1.memo.merge!(memo) } if result.source.equal?(source)

    raise Error::InvalidResultSource.build(given_result: result, expected_source: source)
  end

  def raise_unexpected_outcome_error(result, origin)
    raise Error::UnexpectedOutcome.build(outcome: result, origin: origin, expected: EXPECTED_OUTCOME)
  end

  private_constant :SourceMethodArity
end
