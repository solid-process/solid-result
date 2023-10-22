# frozen_string_literal: true

class BCDD::Result
  class Success < self
    require_relative 'success/methods'

    include Methods
  end

  def self.Success(type, value = nil)
    Success.new(type: type, value: value)
  end
end
