# frozen_string_literal: true

class BCDD::Result
  class Error < ::StandardError
    class NotImplemented < self
    end

    class MissingTypeArgument < self
      def initialize(_arg = nil)
        super('a type must be defined')
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
