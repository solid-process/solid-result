# frozen_string_literal: true

class BCDD::Result
  class Context < self
    require_relative 'context/accumulator'
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

    HashValue = ->(value) { (value.is_a?(::Hash) and value) or raise ::ArgumentError, 'value must be a Hash' }

    def initialize(value:, acc: Accumulator::EMPTY_DATA, **options)
      HashValue[value]

      @acc = acc

      super(value: value, **options)
    end

    def and_then(method_name = nil, **context_data, &block)
      super(method_name, context_data, &block)
    end

    private

    attr_reader :acc

    SubjectMethodArity = ->(method) do
      return 0 if method.arity.zero?
      return 1 if method.parameters.map(&:first).all?(/\Akey/)

      -1
    end

    def call_subject_method(method_name, context)
      method = subject.method(method_name)

      acc.merge!(value.merge(context))

      result =
        case SubjectMethodArity[method]
        when 0 then subject.send(method_name)
        when 1 then subject.send(method_name, **acc)
        else raise Error::InvalidSubjectMethodArity.build(subject: subject, method: method, max_arity: 1)
        end

      ensure_result_object(result, origin: :method)
    end

    def ensure_result_object(result, origin:)
      raise Error::UnexpectedOutcome.build(outcome: result, origin: origin, context: true) unless result.is_a?(Context)

      return result if result.subject.equal?(subject)

      raise Error::InvalidResultSubject.build(given_result: result, expected_subject: subject)
    end

    private_constant :SubjectMethodArity
  end
end
