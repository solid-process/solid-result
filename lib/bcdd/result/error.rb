# frozen_string_literal: true

class BCDD::Result
  class Error < ::StandardError
    class NotImplemented < self
    end

    class MissingTypeArgument < self
      def initialize(_arg = nil)
        super('A type (argument) is required to invoke the #on/#on_type method')
      end
    end

    class UnexpectedBlockOutcome < self
      def initialize(arg = nil)
        message =
          "Unexpected outcome: #{arg.inspect}. The block must return this object wrapped by " \
          'BCDD::Result::Success or BCDD::Result::Failure'

        super(message)
      end
    end
  end
end
