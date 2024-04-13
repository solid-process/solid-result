# frozen_string_literal: true

class Solid::Result
  class Failure < self
    include ::Solid::Failure
  end

  def self.Failure(type, value = nil)
    Failure.new(type: type, value: value)
  end
end
