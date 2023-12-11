# frozen_string_literal: true

class BCDD::Result::Context
  class Expectations < BCDD::Result::Expectations
    require_relative 'expectations/mixin'

    def self.mixin_module
      Mixin
    end

    def self.result_factory_without_expectations
      ::BCDD::Result::Context
    end

    private_class_method :mixin!, :mixin_module, :result_factory_without_expectations

    def Success(type, **value)
      Success.new(type: type, value: value, subject: subject, expectations: contract)
    end

    def Failure(type, **value)
      Failure.new(type: type, value: value, subject: subject, expectations: contract)
    end
  end
end
