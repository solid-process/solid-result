# frozen_string_literal: true

class BCDD::Result
  class Type
    attr_reader :to_sym

    def initialize(type)
      @to_sym = type.to_sym
    end

    def in?(types, allow_empty: false)
      (allow_empty && types.empty?) || types.any?(to_sym)
    end
  end

  private_constant :Type
end
