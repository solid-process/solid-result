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
  end
end
