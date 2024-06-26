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
      const_defined?(:Input, false) and raise ArgumentError, "#{self}::Input class already defined"

      unless klass.is_a?(::Class) && klass < Input
        raise ArgumentError, 'must be a ApplicationService::Input subclass'
      end

      const_set(:Input, klass)
    end

    def input(&block)
      return const_get(:Input, false) if const_defined?(:Input, false)

      klass = ::Class.new(Input)
      klass.class_eval(&block)

      self.input = klass
    end

    def inherited(subclass)
      subclass.include ::Solid::Output.mixin(config: { addon: { continue: true } })
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
    ::Solid::Result.event_logs(name: self.class.name) do
      if input.invalid?
        Failure(:invalid_input, input: input)
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
