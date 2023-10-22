# frozen_string_literal: true

class BCDD::Result::Error < StandardError
  def self.build(**_kargs)
    new
  end

  class NotImplemented < self
  end

  class MissingTypeArgument < self
    def initialize(_arg = nil)
      super('A type (argument) is required to invoke the #on/#on_type method')
    end
  end

  class UnexpectedOutcome < self
    def self.build(outcome:, origin:, context: false)
      success = context ? 'BCDD::Result::Context::Success' : 'BCDD::Result::Success'
      failure = context ? 'BCDD::Result::Context::Failure' : 'BCDD::Result::Failure'

      message =
        "Unexpected outcome: #{outcome.inspect}. The #{origin} must return this object wrapped by " \
        "#{success} or #{failure}"

      new(message)
    end
  end

  class WrongResultSubject < self
    def self.build(given_result:, expected_subject:)
      message =
        "You cannot call #and_then and return a result that does not belong to the subject!\n" \
        "Expected subject: #{expected_subject.inspect}\n" \
        "Given subject: #{given_result.send(:subject).inspect}\n" \
        "Given result: #{given_result.inspect}"

      new(message)
    end
  end

  class WrongSubjectMethodArity < self
    def self.build(subject:, method:, max_arity:)
      new("#{subject.class}##{method.name} has unsupported arity (#{method.arity}). Expected 0..#{max_arity}")
    end
  end

  class UnhandledTypes < self
    def self.build(types:)
      subject = types.size == 1 ? 'This was' : 'These were'

      new("You must handle all cases. #{subject} not handled: #{types.map(&:inspect).join(', ')}")
    end
  end
end
