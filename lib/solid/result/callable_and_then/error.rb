# frozen_string_literal: true

class Solid::Result
  class CallableAndThen::Error < Error
    class InvalidArity < self
      def self.build(source:, method:, arity:)
        new("Invalid arity for #{source.class}##{method} method. Expected arity: #{arity}")
      end
    end
  end
end
