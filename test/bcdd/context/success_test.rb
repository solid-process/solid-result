# frozen_string_literal: true

require 'test_helper'

module BCDD
  class ContextSuccessTest < Minitest::Test
    test 'is a BCDD::Context' do
      assert Context::Success < BCDD::Context
    end

    test 'is a BCDD::Success' do
      assert Context::Success < BCDD::Success
    end

    test '#inspect' do
      result = Context::Success(:ok, number: 1)

      assert_equal(
        '#<BCDD::Context::Success type=:ok value={:number=>1}>',
        result.inspect
      )
    end
  end
end
