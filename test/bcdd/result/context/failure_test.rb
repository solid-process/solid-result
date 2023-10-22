# frozen_string_literal: true

require 'test_helper'

class BCDD::Result
  class ContextFailureTest < Minitest::Test
    test 'is a BCDD::Result::Context' do
      assert Context::Failure < BCDD::Result::Context
    end

    test 'has BCDD::Result::Failure::Methods' do
      assert Context::Failure < BCDD::Result::Failure::Methods
    end

    test '#inspect' do
      result = Context::Failure(:err, number: 0)

      assert_equal(
        '#<BCDD::Result::Context::Failure type=:err value={:number=>0}>',
        result.inspect
      )
    end
  end
end
