# frozen_string_literal: true

require 'test_helper'

module BCDD::Result::Expectations
  class ContractForTypesAndValuesTest < Minitest::Test
    test '#type?' do
      contract = Contract::ForTypesAndValues.new(
        ok: Object
      )

      assert contract.type?(:ok)
      refute contract.type?(:yes)
    end
  end
end
