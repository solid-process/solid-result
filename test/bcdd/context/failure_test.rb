# frozen_string_literal: true

require 'test_helper'

module BCDD
  class ContextFailureTest < Minitest::Test
    test 'is a BCDD::Context' do
      assert Context::Failure < BCDD::Context
    end

    test 'is a BCDD::Failure' do
      assert Context::Failure < BCDD::Failure
    end

    test '#inspect' do
      result = Context::Failure(:err, number: 0)

      assert_equal(
        '#<BCDD::Context::Failure type=:err value={:number=>0}>',
        result.inspect
      )
    end
  end
end
