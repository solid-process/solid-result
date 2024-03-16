# frozen_string_literal: true

class BCDD::Result
  class Failure < self
    include ::BCDD::Failure
  end

  def self.Failure(type, value = nil)
    Failure.new(type: type, value: value)
  end
end
