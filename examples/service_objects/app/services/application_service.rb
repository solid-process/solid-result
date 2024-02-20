# frozen_string_literal: true

class ApplicationService
  Error = ::Class.new(::StandardError)

  class Input
    def self.inherited(subclass)
      subclass.include ::ActiveModel::API
      subclass.include ::ActiveModel::Attributes
      subclass.include ::ActiveModel::Dirty
      subclass.include ::ActiveModel::Validations::Callbacks
    end
  end

  class << self
    def input=(klass)
      const_defined?(:Input, false) and raise ArgumentError, 'Attributes class already defined'

      unless klass.is_a?(::Class) && klass < (ApplicationService::Input)
        raise ArgumentError, 'must be a ApplicationService::Attributes subclass'
      end

      const_set(:Input, klass)
    end

    def input(&block)
      return const_get(:Input, false) if const_defined?(:Input, false)

      klass = ::Class.new(ApplicationService::Input)
      klass.class_eval(&block)

      self.input = klass
    end

    def inherited(subclass)
      subclass.include ::BCDD::Result::Context.mixin(config: { addon: { continue: true } })
    end

    def call(arg)
      new(input.new(arg)).call!
    end
  end

  private_class_method :new

  attr_reader :input

  def initialize(input)
    @input = input
  end

  def call!
    ::BCDD::Result.transitions(name: self.class.name) do
      if input.invalid?
        Failure(:invalid_input, **input.errors.messages)
      else
        call(input.attributes.deep_symbolize_keys)
      end
    end
  end

  def call(attributes)
    raise Error, 'must be implemented in a subclass'
  end

  private

  def rollback_on_failure(model: ::ActiveRecord::Base)
    result = nil

    model.transaction do
      result = yield

      raise ::ActiveRecord::Rollback if result.failure?
    end

    result
  end
end
