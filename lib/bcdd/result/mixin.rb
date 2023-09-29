# frozen_string_literal: true

class BCDD::Result
  module Mixin
    def Success(type, value = nil)
      Success.new(type: type, value: value, subject: self)
    end

    def Failure(type, value = nil)
      Failure.new(type: type, value: value, subject: self)
    end
  end
end
