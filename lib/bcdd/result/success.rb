# frozen_string_literal: true

class BCDD::Result
  class Success < self
    include ::BCDD::Success
  end

  def self.Success(type, value = nil)
    Success.new(type: type, value: value)
  end
end
