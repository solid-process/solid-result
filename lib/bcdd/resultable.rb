# frozen_string_literal: true

module BCDD::Resultable
  def Success(type, value = nil)
    BCDD::Result::Success.new(type: type, value: value, subject: self)
  end

  def Failure(type, value = nil)
    BCDD::Result::Failure.new(type: type, value: value, subject: self)
  end
end
