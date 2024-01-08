# frozen_string_literal: true

class BCDD::Result::Error < StandardError
  def self.build(**_kargs)
    new
  end

  class NotImplemented < self
  end

  class MissingTypeArgument < self
    def initialize(_message = nil)
      super('A type (argument) is required to invoke the #on/#on_type method')
    end
  end

  class UnexpectedOutcome < self
    def self.build(outcome:, origin:, expected: nil)
      expected ||= 'BCDD::Result::Success or BCDD::Result::Failure'

      new("Unexpected outcome: #{outcome.inspect}. The #{origin} must return this object wrapped by #{expected}")
    end
  end

  class InvalidResultSource < self
    def self.build(given_result:, expected_source:)
      message =
        "You cannot call #and_then and return a result that does not belong to the same source!\n" \
        "Expected source: #{expected_source.inspect}\n" \
        "Given source: #{given_result.send(:source).inspect}\n" \
        "Given result: #{given_result.inspect}"

      new(message)
    end
  end

  class InvalidSourceMethodArity < self
    def self.build(source:, method:, max_arity:)
      new("#{source.class}##{method.name} has unsupported arity (#{method.arity}). Expected 0..#{max_arity}")
    end
  end

  class UnhandledTypes < self
    def self.build(types:)
      source = types.size == 1 ? 'This was' : 'These were'

      new("You must handle all cases. #{source} not handled: #{types.map(&:inspect).join(', ')}")
    end
  end

  class CallableAndThenDisabled < self
    def initialize(_message = nil)
      super(
        'You cannot use #and_then! as the feature is disabled. ' \
        'Please use BCDD::Result.config.feature.enable!(:and_then!) to enable it.'
      )
    end
  end
end
