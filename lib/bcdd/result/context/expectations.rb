# frozen_string_literal: true

class BCDD::Result::Context
  class Expectations
    require_relative 'expectations/mixin'

    def self.mixin(success: nil, failure: nil, config: nil)
      addons = Mixin::Addons.options(config)

      mod = ::BCDD::Result::Expectations::Mixin.module!
      mod.const_set(:Result, new(success: success, failure: failure).freeze)
      mod.module_eval(Mixin::METHODS)
      mod.send(:include, *addons) unless addons.empty?
      mod
    end

    def initialize(subject: nil, success: nil, failure: nil, contract: nil)
      @subject = subject

      @contract = contract if contract.is_a?(::BCDD::Result::Contract::Evaluator)

      @contract ||= ::BCDD::Result::Contract.new(success: success, failure: failure).freeze
    end

    def Success(type, **value)
      Success.new(type: type, value: value, subject: subject, expectations: contract)
    end

    def Failure(type, **value)
      Failure.new(type: type, value: value, subject: subject, expectations: contract)
    end

    def with(subject:)
      self.class.new(subject: subject, contract: contract)
    end

    private

    attr_reader :subject, :contract
  end
end
