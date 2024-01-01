# frozen_string_literal: true

class BCDD::Result
  class Expectations
    require_relative 'expectations/mixin'

    def self.mixin(**options)
      return mixin!(**options) if Config.instance.feature.enabled?(:expectations)

      result_factory_without_expectations.mixin(**options.slice(:config))
    end

    def self.mixin!(success: nil, failure: nil, config: nil)
      addons = mixin_module::Addons.options(config)

      mod = mixin_module::Factory.module!
      mod.const_set(:Result, new(success: success, failure: failure, config: config).freeze)
      mod.module_eval(mixin_module::Methods.to_eval(addons), __FILE__, __LINE__ + 1)
      mod.send(:include, *addons.values) unless addons.empty?
      mod
    end

    def self.mixin_module
      Mixin
    end

    def self.result_factory_without_expectations
      ::BCDD::Result
    end

    def self.new(...)
      return result_factory_without_expectations unless Config.instance.feature.enabled?(:expectations)

      instance = allocate
      instance.send(:initialize, ...)
      instance
    end

    private_class_method :mixin!, :mixin_module, :result_factory_without_expectations

    def initialize(subject: nil, contract: nil, terminal: nil, **options)
      @terminal = terminal

      @subject = subject

      @contract = contract if contract.is_a?(Contract::Evaluator)

      @contract ||= Contract.new(
        success: options[:success],
        failure: options[:failure],
        config: options[:config]
      ).freeze
    end

    def Success(type, value = nil)
      _ResultAs(Success, type, value)
    end

    def Failure(type, value = nil)
      _ResultAs(Failure, type, value)
    end

    def with(subject:, terminal: nil)
      self.class.new(subject: subject, terminal: terminal, contract: contract)
    end

    private

    def _ResultAs(kind_class, type, value)
      kind_class.new(type: type, value: value, subject: subject, expectations: contract, terminal: terminal)
    end

    attr_reader :subject, :terminal, :contract
  end
end
