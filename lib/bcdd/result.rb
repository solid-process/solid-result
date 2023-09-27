# frozen_string_literal: true

require_relative 'result/version'
require_relative 'result/error'
require_relative 'result/failure'
require_relative 'result/success'
require_relative 'result/type'

require_relative 'resultable'

class BCDD::Result
  attr_reader :type, :value, :subject

  protected :subject

  def initialize(type:, value:, subject: nil)
    @type = type.to_sym
    @value = value
    @subject = subject
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

  def ==(other)
    self.class == other.class && type == other.type && value == other.value
  end
  alias eql? ==

  def hash
    [self.class, type, value].hash
  end

  def inspect
    format('#<%<class_name>s type=%<type>p value=%<value>p>', class_name: self.class.name, type: type, value: value)
  end

  def on(*types)
    raise Error::MissingTypeArgument if types.empty?

    tap { yield(value, type) if expected_type?(types) }
  end

  def on_success(*types)
    tap { yield(value, type) if success? && allowed_to_handle?(types) }
  end

  def on_failure(*types)
    tap { yield(value, type) if failure? && allowed_to_handle?(types) }
  end

  def and_then(method_name = nil)
    return self if failure?

    return call_subject_method(method_name) if method_name

    result = yield(value)

    ensure_result_object(result, origin: :block)
  end

  alias data value
  alias data_or value_or
  alias on_type on

  private

  def expected_type?(types)
    types.any?(type)
  end

  def allowed_to_handle?(types)
    types.empty? || expected_type?(types)
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
