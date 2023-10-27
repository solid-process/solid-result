# frozen_string_literal: true

class BCDD::Result
  class Failure < self
    require_relative 'failure/methods'

    include Methods
  end

  def self.Failure(type, value = nil)
    Failure.new(type: type, value: value)
  end
end
