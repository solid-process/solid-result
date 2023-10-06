# frozen_string_literal: true

module BCDD::Result::Expectations
  require_relative 'expectations/contract'
  require_relative 'expectations/type_checker'

  MIXIN_METHODS = <<~RUBY
    def Success(type, value = nil)
      ::BCDD::Result::Success.new(type: type, value: value, subject: self, expectations: EXPECTATIONS)
    end

    def Failure(type, value = nil)
      ::BCDD::Result::Failure.new(type: type, value: value, subject: self, expectations: EXPECTATIONS)
    end
  RUBY

  def self.mixin(success: nil, failure: nil)
    contract = Contract.new(success: success, failure: failure).freeze

    mod = Module.new
    mod.const_set(:EXPECTATIONS, contract)
    mod.module_eval(MIXIN_METHODS)
    mod
  end

  def self.evaluate(data, expectations)
    expectations ||= Contract::NONE

    expectations.type_and_value!(data)

    TypeChecker.new(data.type, expectations: expectations)
  end
end
