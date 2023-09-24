# frozen_string_literal: true

module BCDD::Result
  class Error < ::StandardError
    class NotImplemented < self
    end

    class MissingTypeArgument < self
      def initialize(_message = nil)
        super('a type must be defined')
      end
    end

    class UnexpectedBlockResult < self
      def initialize(_message = nil)
        super('block must return a BCDD::Result::Success or BCDD::Result::Failure')
      end
    end
  end
end
