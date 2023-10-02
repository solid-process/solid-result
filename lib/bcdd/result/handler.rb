# frozen_string_literal: true

class BCDD::Result
  class Handler
    UNDEFINED = ::Object.new

    def initialize(result, type_checker:)
      @outcome = UNDEFINED

      @result = result
      @type_checker = type_checker
    end

    def [](*types, &block)
      raise Error::MissingTypeArgument if types.empty?

      self.outcome = block if type_checker.allow?(types)
    end

    def failure(*types, &block)
      self.outcome = block if result.failure? && type_checker.allow_failure?(types)
    end

    def success(*types, &block)
      self.outcome = block if result.success? && type_checker.allow_success?(types)
    end

    def unknown(&block)
      self.outcome = block unless outcome?
    end

    alias type []

    private

    attr_reader :result, :type_checker

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
