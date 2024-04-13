# frozen_string_literal: true

module Solid::Result::Contract
  class TypeChecker
    attr_reader :result_type, :expectations

    def initialize(result_type, expectations:)
      @result_type = result_type

      @expectations = expectations
    end

    def allow!(type)
      expectations.type!(type)
    end

    def allow?(types)
      validate(types, expected: expectations, allow_empty: false)
    end

    def allow_success?(types)
      validate(types, expected: expectations.success, allow_empty: true)
    end

    def allow_failure?(types)
      validate(types, expected: expectations.failure, allow_empty: true)
    end

    private

    def validate(types, expected:, allow_empty:)
      (allow_empty && types.empty?) || types.any? { |type| expected.type!(type) == result_type }
    end
  end

  private_constant :TypeChecker
end
