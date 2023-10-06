# frozen_string_literal: true

class BCDD::Result::Expectations
  require_relative 'expectations/contract'
  require_relative 'expectations/type_checker'

  MIXIN_METHODS = <<~RUBY
    def Success(...)
      _expected_result::Success(...)
    end

    def Failure(...)
      _expected_result::Failure(...)
    end

    private

    def _expected_result
      @_expected_result ||= Expected.with(subject: self)
    end
  RUBY

  def self.mixin(success: nil, failure: nil)
    mod = Module.new
    mod.const_set(:Expected, new(success: success, failure: failure).freeze)
    mod.module_eval(MIXIN_METHODS)
    mod
  end

  def self.evaluate(data, expectations)
    expectations ||= Contract::NONE

    expectations.type_and_value!(data)

    TypeChecker.new(data.type, expectations: expectations)
  end

  def initialize(subject: nil, success: nil, failure: nil, contract: nil)
    @subject = subject

    @contract = contract if contract.is_a?(Contract::Evaluator)

    @contract ||= Contract.new(success: success, failure: failure).freeze
  end

  def Success(type, value = nil)
    ::BCDD::Result::Success.new(type: type, value: value, subject: subject, expectations: contract)
  end

  def Failure(type, value = nil)
    ::BCDD::Result::Failure.new(type: type, value: value, subject: subject, expectations: contract)
  end

  def with(subject:)
    self.class.new(subject: subject, contract: contract)
  end

  private

  attr_reader :subject, :contract
end
