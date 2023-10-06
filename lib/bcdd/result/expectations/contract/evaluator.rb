# frozen_string_literal: true

module BCDD::Result::Expectations::Contract
  class Evaluator
    include Interface

    attr_reader :allowed_types, :success, :failure

    def initialize(success, failure)
      @success = success
      @failure = failure

      @allowed_types = (success.allowed_types | failure.allowed_types).freeze
    end

    def type?(type)
      return success.type?(type) if success != Disabled
      return failure.type?(type) if failure != Disabled

      Disabled.type?(type)
    end

    def type!(type)
      return type if type?(type)

      raise Error::UnexpectedType.build(type: type, allowed_types: allowed_types)
    end

    def type_and_value!(data)
      self.for(data).type_and_value!(data)
    end

    private

    def for(data)
      case data.name
      when :unknown then Disabled
      when :success then success
      else failure
      end
    end
  end
end
