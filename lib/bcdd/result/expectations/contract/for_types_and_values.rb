# frozen_string_literal: true

class BCDD::Result::Expectations
  class Contract::ForTypesAndValues
    include Contract::Interface

    def initialize(types_and_values)
      @types_and_values = types_and_values.transform_keys(&:to_sym)

      @types_contract = Contract::ForTypes.new(@types_and_values.keys)
    end

    def allowed_types
      @types_contract.allowed_types
    end

    def type?(type)
      @types_contract.type?(type)
    end

    def type!(type)
      @types_contract.type!(type)
    end

    def type_and_value!(data)
      type = data.type
      value = data.value
      allowed_value = @types_and_values[type!(type)]

      return value if allowed_value === value

      raise Error::UnexpectedValue.build(type: type, value: value)
    rescue ::NoMatchingPatternError => e
      raise Error::UnexpectedValue.build(type: data.type, value: data.value, cause: e)
    end
  end
end
