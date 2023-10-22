# frozen_string_literal: true

require 'test_helper'

class BCDD::Result
  class ContextSuccessTest < Minitest::Test
    test 'is a BCDD::Result::Context' do
      assert Context::Success < BCDD::Result::Context
    end

    test 'has BCDD::Result::Success::Methods' do
      assert Context::Success < BCDD::Result::Success::Methods
    end

    test '#inspect' do
      result = Context::Success(:ok, number: 1)

      assert_equal(
        '#<BCDD::Result::Context::Success type=:ok value={:number=>1}>',
        result.inspect
      )
    end
  end
end
