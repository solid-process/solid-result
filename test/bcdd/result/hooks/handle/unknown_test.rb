# frozen_string_literal: true

require 'test_helper'

class BCDD::Result
  class HandleUnknownTest < Minitest::Test
    test '#handle ignores unknown when a success handler is called' do
      result = Success.new(type: :foo, value: :bar)

      outcome = result.handle do |on|
        on.success { 1 }
        on.unknown { raise }
      end

      assert_equal 1, outcome
    end

    test '#handle ignores unknown when a failure handler is called' do
      result = Failure.new(type: :foo, value: :bar)

      outcome = result.handle do |on|
        on.failure { 0 }
        on.unknown { raise }
      end

      assert_equal 0, outcome
    end

    test '#handle calls unknown handler when no other is called' do
      result = Success.new(type: :foo, value: :bar)

      outcome = result.handle do |on|
        on[:bar] { raise }
        on.success(:bar) { raise }
        on.failure { raise }
        on.unknown { 3 }
      end

      assert_equal 3, outcome
    end
  end
end
