# frozen_string_literal: true

class Solid::Result
  class Contract::Evaluator
    include Contract::Interface

    attr_reader :allowed_types, :success, :failure

    def initialize(success, failure)
      @success = success
      @failure = failure

      @allowed_types = (success.allowed_types | failure.allowed_types).freeze
    end

    def type?(type)
      success_disabled = success == Contract::Disabled
      failure_disabled = failure == Contract::Disabled

      return Contract::Disabled.type?(type) if success_disabled && failure_disabled

      (!success_disabled && success.type?(type)) || (!failure_disabled && failure.type?(type))
    end

    def type!(type)
      return type if type?(type)

      raise Contract::Error::UnexpectedType.build(type: type, allowed_types: allowed_types)
    end

    def type_and_value!(data)
      self.for(data).type_and_value!(data)
    end

    private

    def for(data)
      case data.kind
      when :unknown then Contract::Disabled
      when :success then success
      else failure
      end
    end
  end
end
