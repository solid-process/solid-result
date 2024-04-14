# frozen_string_literal: true

require 'test_helper'

class Solid::Result
  class Contract::ForTypesAndValuesTest < Minitest::Test
    test '#type?' do
      contract = Contract::ForTypesAndValues.new({ ok: Object }, nil)

      assert contract.type?(:ok)
      refute contract.type?(:yes)
    end
  end
end
