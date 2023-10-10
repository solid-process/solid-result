# frozen_string_literal: true

class BCDD::Result::Expectations
  module Contract
    require_relative 'contract/interface'
    require_relative 'contract/evaluator'
    require_relative 'contract/disabled'
    require_relative 'contract/for_types'
    require_relative 'contract/for_types_and_values'

    NONE = Contract::Evaluator.new(Contract::Disabled, Contract::Disabled).freeze

    ToEnsure = ->(spec) do
      return Contract::Disabled if spec.nil?

      spec.is_a?(Hash) ? Contract::ForTypesAndValues.new(spec) : Contract::ForTypes.new(Array(spec))
    end

    def self.new(success:, failure:)
      Contract::Evaluator.new(ToEnsure[success], ToEnsure[failure])
    end

    private_constant :ToEnsure
  end
end
