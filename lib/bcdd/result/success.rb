# frozen_string_literal: true

class BCDD::Result
  class Success < self
    def success?(type = nil)
      type.nil? || type == self.type
    end

    def failure?(_type = nil)
      false
    end

    def value_or
      value
    end

    alias data_or value_or
  end

  def self.Success(type, value = nil)
    Success.new(type: type, value: value)
  end
end
