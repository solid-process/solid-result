# frozen_string_literal: true

class Solid::Output
  class Expectations < Solid::Result::Expectations
    require_relative 'expectations/mixin'

    def self.mixin_module
      Mixin
    end

    def self.result_factory_without_expectations
      ::Solid::Output
    end

    private_class_method :mixin!, :mixin_module, :result_factory_without_expectations

    def Success(type, **value)
      _ResultAs(Success, type, value)
    end

    def Failure(type, **value)
      _ResultAs(Failure, type, value)
    end
  end
end
