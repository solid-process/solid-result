# frozen_string_literal: true

class BCDD::Result
  class Failure < self
    def success?(_type = nil)
      false
    end

    def failure?(type = nil)
      type.nil? || type_checker.allow_failure?([type])
    end

    def value_or
      yield
    end

    private

    def name
      :failure
    end
  end

  def self.Failure(type, value = nil)
    Failure.new(type: type, value: value)
  end
end
