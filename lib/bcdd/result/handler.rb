# frozen_string_literal: true

class BCDD::Result
  class Handler
    require_relative 'handler/types_allowed'

    UNDEFINED = ::Object.new

    def initialize(result, type_checker:)
      @types_allowed = TypesAllowed.new(type_checker)

      @outcome = UNDEFINED

      @result = result
    end

    def [](*types, &block)
      raise Error::MissingTypeArgument if types.empty?

      self.outcome = block if types_allowed.allow?(types)
    end

    def success(*types, &block)
      self.outcome = block if types_allowed.allow_success?(types) && result.success?
    end

    def failure(*types, &block)
      self.outcome = block if types_allowed.allow_failure?(types) && result.failure?
    end

    def unknown(&block)
      self.outcome = block unless outcome?
    end

    alias type []

    private

    attr_reader :result, :types_allowed

    def outcome?
      @outcome != UNDEFINED
    end

    def outcome=(block)
      @outcome = block.call(result.value, result.type) unless outcome?
    end

    def outcome
      types_allowed.all_checked? or raise Error::UnhandledTypes.build(types: types_allowed.unchecked)

      @outcome if outcome?
    end
  end

  private_constant :Handler
end
