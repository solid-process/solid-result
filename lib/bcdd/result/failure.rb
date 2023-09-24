# frozen_string_literal: true

class BCDD::Result
  class Failure < self
    def success?(_type = nil)
      false
    end

    def failure?(type = nil)
      type.nil? || type == self.type
    end

    def value_or
      yield
    end

    alias data_or value_or
  end

  def self.Failure(type, value = nil)
    Failure.new(type: type, value: value)
  end
end
