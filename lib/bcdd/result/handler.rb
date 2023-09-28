# frozen_string_literal: true

class BCDD::Result
  class Handler
    UNDEFINED = ::Object.new

    def initialize(result)
      @outcome = UNDEFINED

      @_type = result._type
      @result = result
    end

    def [](*types, &block)
      raise Error::MissingTypeArgument if types.empty?

      self.outcome = block if _type.in?(types, allow_empty: false)
    end

    def failure(*types, &block)
      self.outcome = block if result.failure? && _type.in?(types, allow_empty: true)
    end

    def success(*types, &block)
      self.outcome = block if result.success? && _type.in?(types, allow_empty: true)
    end

    def unknown(&block)
      self.outcome = block unless outcome?
    end

    alias type []

    private

    attr_reader :_type, :result

    def outcome?
      @outcome != UNDEFINED
    end

    def outcome=(block)
      @outcome = block.call(result.value, result.type) unless outcome?
    end

    def outcome
      @outcome if outcome?
    end
  end

  private_constant :Handler
end
