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

    def initialize(type:, value:, subject: nil, expectations: nil, halted: nil)
      value.is_a?(::Hash) or raise ::ArgumentError, 'value must be a Hash'

      @acc = {}

      super
    end

    def and_then(method_name = nil, **context_data, &block)
      super(method_name, context_data, &block)
    end

    protected

    attr_reader :acc

    private

    SubjectMethodArity = ->(method) do
      return 0 if method.arity.zero?
      return 1 if method.parameters.map(&:first).all?(/\Akey/)

      -1
    end

    def call_and_then_subject_method(method_name, context)
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

    def call_and_then_block(block)
      acc.merge!(value)

      call_and_then_block!(block, acc)
    end

    def ensure_result_object(result, origin:)
      raise_unexpected_outcome_error(result, origin) unless result.is_a?(Context)

      return result.tap { _1.acc.merge!(acc) } if result.subject.equal?(subject)

      raise Error::InvalidResultSubject.build(given_result: result, expected_subject: subject)
    end

    EXPECTED_OUTCOME = 'BCDD::Result::Context::Success or BCDD::Result::Context::Failure'

    def raise_unexpected_outcome_error(result, origin)
      raise Error::UnexpectedOutcome.build(outcome: result, origin: origin, expected: EXPECTED_OUTCOME)
    end

    private_constant :SubjectMethodArity, :EXPECTED_OUTCOME
  end
end
