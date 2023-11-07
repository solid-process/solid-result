# frozen_string_literal: true

class BCDD::Result
  class Expectations
    require_relative 'expectations/mixin'

    def self.mixin(success: nil, failure: nil, config: nil)
      addons = mixin_module::Addons.options(config)

      mod = mixin_module::Factory.module!
      mod.const_set(:Result, new(success: success, failure: failure).freeze)
      mod.module_eval(mixin_module::METHODS)
      mod.send(:include, *addons) unless addons.empty?
      mod
    end

    def self.mixin_module
      Mixin
    end

    private_class_method :mixin_module

    def initialize(subject: nil, success: nil, failure: nil, contract: nil)
      @subject = subject

      @contract = contract if contract.is_a?(Contract::Evaluator)

      @contract ||= Contract.new(success: success, failure: failure).freeze
    end

    def Success(type, value = nil)
      Success.new(type: type, value: value, subject: subject, expectations: contract)
    end

    def Failure(type, value = nil)
      Failure.new(type: type, value: value, subject: subject, expectations: contract)
    end

    def with(subject:)
      self.class.new(subject: subject, contract: contract)
    end

    private

    attr_reader :subject, :contract
  end
end
