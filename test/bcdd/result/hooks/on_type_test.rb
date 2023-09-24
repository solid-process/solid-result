# frozen_string_literal: true

require 'test_helper'

class BCDD::Result
  class OnTypeHookTest < Minitest::Test
    test '#on_type is an alias for #on' do
      success = Success.new(type: :okay, value: 1)
      failure = Failure.new(type: :nokay, value: nil)

      assert_equal success.method(:on), success.method(:on_type)
      assert_equal failure.method(:on), failure.method(:on_type)
    end
  end
end
