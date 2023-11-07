# frozen_string_literal: true

class BCDD::Result::Context
  class Expectations < BCDD::Result::Expectations
    require_relative 'expectations/mixin'

    def self.mixin_module
      Mixin
    end

    private_class_method :mixin_module

    def Success(type, **value)
      Success.new(type: type, value: value, subject: subject, expectations: contract)
    end

    def Failure(type, **value)
      Failure.new(type: type, value: value, subject: subject, expectations: contract)
    end
  end
end
