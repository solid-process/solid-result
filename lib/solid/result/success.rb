# frozen_string_literal: true

class Solid::Result
  class Success < self
    include ::Solid::Success
  end

  def self.Success(type, value = nil)
    Success.new(type: type, value: value)
  end
end
