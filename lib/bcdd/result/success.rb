# frozen_string_literal: true

class BCDD::Result
  class Success < self
    def success?(type = nil)
      type.nil? || type_checker.allow_success?([type])
    end

    def failure?(_type = nil)
      false
    end

    def value_or
      value
    end

    private

    def name
      :success
    end
  end

  def self.Success(type, value = nil)
    Success.new(type: type, value: value)
  end
end
