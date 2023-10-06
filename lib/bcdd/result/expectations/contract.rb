# frozen_string_literal: true

module BCDD::Result::Expectations::Contract
  require_relative 'contract/error'
  require_relative 'contract/interface'
  require_relative 'contract/evaluator'
  require_relative 'contract/disabled'
  require_relative 'contract/for_types'
  require_relative 'contract/for_types_and_values'

  NONE = Evaluator.new(Disabled, Disabled).freeze

  ToEnsure = ->(spec) do
    return Disabled if spec.nil?

    spec.is_a?(Hash) ? ForTypesAndValues.new(spec) : ForTypes.new(Array(spec))
  end

  def self.new(success:, failure:)
    Evaluator.new(ToEnsure[success], ToEnsure[failure])
  end

  private_constant :ToEnsure
end
