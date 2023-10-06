# frozen_string_literal: true

class BCDD::Result
  class Handler
    require_relative 'handler/allowed_types'

    UNDEFINED = ::Object.new

    def initialize(result, type_checker:)
      @allowed_types = AllowedTypes.new(type_checker)

      @outcome = UNDEFINED

      @result = result
    end

    def [](*types, &block)
      raise Error::MissingTypeArgument if types.empty?

      self.outcome = block if allowed_types.allow?(types)
    end

    def success(*types, &block)
      self.outcome = block if allowed_types.allow_success?(types) && result.success?
    end

    def failure(*types, &block)
      self.outcome = block if allowed_types.allow_failure?(types) && result.failure?
    end

    def unknown(&block)
      self.outcome = block unless outcome?
    end

    alias type []

    private

    attr_reader :result, :allowed_types

    def outcome?
      @outcome != UNDEFINED
    end

    def outcome=(block)
      @outcome = block.call(result.value, result.type) unless outcome?
    end

    def outcome
      allowed_types.all_checked? or raise Error::UnhandledTypes.build(types: allowed_types.unchecked)

      @outcome if outcome?
    end
  end

  private_constant :Handler
end
