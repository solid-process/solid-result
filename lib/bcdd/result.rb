# frozen_string_literal: true

require 'singleton'

require_relative 'result/version'
require_relative 'result/error'
require_relative 'result/transitions'
require_relative 'result/callable_and_then'
require_relative 'result/data'
require_relative 'result/handler'
require_relative 'result/failure'
require_relative 'result/success'
require_relative 'result/mixin'
require_relative 'result/contract'
require_relative 'result/expectations'
require_relative 'result/context'
require_relative 'result/config'

class BCDD::Result
  attr_accessor :unknown, :transitions

  attr_reader :source, :data, :type_checker, :terminal

  protected :source

  private :unknown, :unknown=, :type_checker, :transitions=

  def self.config
    Config.instance
  end

  def self.configuration
    yield(config)

    config.freeze
  end

  def initialize(type:, value:, source: nil, expectations: nil, terminal: nil)
    data = Data.new(kind, type, value)

    @type_checker = Contract.evaluate(data, expectations)
    @source = source
    @terminal = terminal || kind == :failure
    @data = data

    self.unknown = true
    self.transitions = Transitions::Tracking::EMPTY

    Transitions.tracking.record(self)
  end

  def terminal?
    terminal
  end

  def type
    data.type
  end

  def value
    data.value
  end

  def success?(_type = nil)
    raise Error::NotImplemented
  end

  def failure?(_type = nil)
    raise Error::NotImplemented
  end

  def value_or(&_block)
    raise Error::NotImplemented
  end

  def on(*types, &block)
    raise Error::MissingTypeArgument if types.empty?

    tap { known(block) if type_checker.allow?(types) }
  end

  def on_success(*types, &block)
    tap { known(block) if type_checker.allow_success?(types) && success? }
  end

  def on_failure(*types, &block)
    tap { known(block) if type_checker.allow_failure?(types) && failure? }
  end

  def on_unknown
    tap { yield(value, type) if unknown }
  end

  def and_then(method_name = nil, injected_value = nil, &block)
    return self if terminal?

    method_name && block and raise ::ArgumentError, 'method_name and block are mutually exclusive'

    method_name ? call_and_then_source_method(method_name, injected_value) : call_and_then_block(block)
  end

  def and_then!(source, injected_value = nil, _call: nil)
    raise Error::CallableAndThenDisabled unless Config.instance.feature.enabled?(:and_then!)

    return self if terminal?

    call_and_then_callable!(source, value: value, injected_value: injected_value, method_name: _call)
  end

  def handle
    handler = Handler.new(self, type_checker: type_checker)

    yield handler

    handler.send(:outcome)
  end

  def ==(other)
    self.class == other.class && type == other.type && value == other.value
  end

  def hash
    [self.class, type, value].hash
  end

  def inspect
    format('#<%<class_name>s type=%<type>p value=%<value>p>', class_name: self.class.name, type: type, value: value)
  end

  def deconstruct
    [type, value]
  end

  def deconstruct_keys(_keys)
    { kind => { type => value } }
  end

  alias eql? ==
  alias on_type on

  private

  def kind
    :unknown
  end

  def known(block)
    self.unknown = false

    block.call(value, type)
  end

  def call_and_then_source_method(method_name, injected_value)
    method = source.method(method_name)

    Transitions.tracking.record_and_then(method, injected_value, source) do
      result = call_and_then_source_method!(method, injected_value)

      ensure_result_object(result, origin: :method)
    end
  end

  def call_and_then_source_method!(method, injected_value)
    case method.arity
    when 0 then source.send(method.name)
    when 1 then source.send(method.name, value)
    when 2 then source.send(method.name, value, injected_value)
    else raise Error::InvalidSourceMethodArity.build(source: source, method: method, max_arity: 2)
    end
  end

  def call_and_then_block(block)
    Transitions.tracking.record_and_then(:block, nil, source) do
      result = call_and_then_block!(block)

      ensure_result_object(result, origin: :block)
    end
  end

  def call_and_then_block!(block)
    block.call(value)
  end

  def call_and_then_callable!(source, value:, injected_value:, method_name:)
    CallableAndThen::Caller.call(source, value: value, injected_value: injected_value, method_name: method_name)
  end

  def ensure_result_object(result, origin:)
    raise Error::UnexpectedOutcome.build(outcome: result, origin: origin) unless result.is_a?(::BCDD::Result)

    return result if result.source.equal?(source)

    raise Error::InvalidResultSource.build(given_result: result, expected_source: source)
  end
end
