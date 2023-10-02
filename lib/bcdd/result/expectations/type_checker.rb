# frozen_string_literal: true

module BCDD::Result::Expectations
  class TypeChecker
    attr_reader :result_type

    def initialize(result_type)
      @result_type = result_type
    end

    def allow?(types)
      validate(types, allow_empty: false)
    end

    def allow_success?(types)
      validate(types, allow_empty: true)
    end

    def allow_failure?(types)
      validate(types, allow_empty: true)
    end

    private

    def validate(types, allow_empty:)
      (allow_empty && types.empty?) || types.any?(result_type)
    end
  end
end
