# frozen_string_literal: true

class BCDD::Result::Context
  class Expectations
    require_relative 'expectations/mixin'

    def self.mixin(success: nil, failure: nil, with: nil)
      addons = Mixin::Addons.options(with)

      mod = ::Module.new { def self.included(base); base.include(Accumulator::Enabled) if base.is_a?(::Class); end }
      mod.const_set(:Result, new(success: success, failure: failure).freeze)
      mod.module_eval(Mixin::METHODS)
      mod.send(:include, *addons) unless addons.empty?
      mod
    end

    def initialize(subject: nil, success: nil, failure: nil, contract: nil, acc: Accumulator::EMPTY_DATA)
      @subject = subject
      @acc     = acc

      @contract = contract if contract.is_a?(::BCDD::Result::Contract::Evaluator)

      @contract ||= ::BCDD::Result::Contract.new(success: success, failure: failure).freeze
    end

    def Success(type, **value)
      Success.new(type: type, value: value, subject: subject, expectations: contract, acc: acc)
    end

    def Failure(type, **value)
      Failure.new(type: type, value: value, subject: subject, expectations: contract, acc: acc)
    end

    def with(subject:, acc:)
      self.class.new(subject: subject, contract: contract, acc: acc)
    end

    private

    attr_reader :subject, :contract, :acc
  end
end
