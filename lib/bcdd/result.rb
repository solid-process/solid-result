# frozen_string_literal: true

require_relative 'result/version'
require_relative 'result/error'
require_relative 'result/type'
require_relative 'result/data'
require_relative 'result/handler'
require_relative 'result/failure'
require_relative 'result/success'
require_relative 'result/mixin'

class BCDD::Result
  attr_accessor :unknown

  attr_reader :_type, :subject, :data

  protected :subject

  private :unknown, :unknown=

  def initialize(type:, value:, subject: nil)
    @data = Data.new(name, type, value)
    @_type = Type.new(data.type)
    @subject = subject

    self.unknown = true
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

    tap { known(block) if _type.in?(types, allow_empty: false) }
  end

  def on_success(*types, &block)
    tap { known(block) if success? && _type.in?(types, allow_empty: true) }
  end

  def on_failure(*types, &block)
    tap { known(block) if failure? && _type.in?(types, allow_empty: true) }
  end

  def on_unknown
    tap { yield(value, type) if unknown }
  end

  def and_then(method_name = nil)
    return self if failure?

    return call_subject_method(method_name) if method_name

    result = yield(value)

    ensure_result_object(result, origin: :block)
  end

  def handle
    handler = Handler.new(self)

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
    { name => { type => value } }
  end

  alias eql? ==
  alias on_type on

  private

  def name
    :unknown
  end

  def known(block)
    self.unknown = false

    block.call(value, type)
  end

  def call_subject_method(method_name)
    method = subject.method(method_name)

    result =
      case method.arity
      when 0 then subject.send(method_name)
      when 1 then subject.send(method_name, value)
      else raise Error::WrongSubjectMethodArity.build(subject: subject, method: method)
      end

    ensure_result_object(result, origin: :method)
  end

  def ensure_result_object(result, origin:)
    raise Error::UnexpectedOutcome.build(outcome: result, origin: origin) unless result.is_a?(::BCDD::Result)

    return result if result.subject.equal?(subject)

    raise Error::WrongResultSubject.build(given_result: result, expected_subject: subject)
  end
end
