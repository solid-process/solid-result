# frozen_string_literal: true

module BCDD
  module Failure
    def success?(_type = nil)
      false
    end

    def failure?(type = nil)
      type.nil? || type_checker.allow_failure?([type])
    end

    def value_or
      yield(value)
    end

    private

    def kind
      :failure
    end
  end
end
