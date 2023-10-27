# frozen_string_literal: true

module BCDD::Result::Contract
  require_relative 'contract/error'
  require_relative 'contract/type_checker'
  require_relative 'contract/interface'
  require_relative 'contract/evaluator'
  require_relative 'contract/disabled'
  require_relative 'contract/for_types'
  require_relative 'contract/for_types_and_values'

  NONE = Evaluator.new(Disabled, Disabled).freeze

  def self.evaluate(data, contract)
    contract ||= NONE

    contract.type_and_value!(data)

    TypeChecker.new(data.type, expectations: contract)
  end

  ToEnsure = ->(spec) do
    return Disabled if spec.nil?

    spec.is_a?(::Hash) ? ForTypesAndValues.new(spec) : ForTypes.new(Array(spec))
  end

  def self.new(success:, failure:)
    Evaluator.new(ToEnsure[success], ToEnsure[failure])
  end

  @nil_as_valid_value_checking = false

  def self.nil_as_valid_value_checking!(enabled: true)
    @nil_as_valid_value_checking = enabled
  end

  def self.nil_as_valid_value_checking?
    @nil_as_valid_value_checking
  end

  private_constant :ToEnsure
end
