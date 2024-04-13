# frozen_string_literal: true

require 'test_helper'

class Solid::Result
  class OnUnknownHookTest < Minitest::Test
    test '#on_unknown is ignored when a success hook is called' do
      Success
        .new(type: :bar, value: :foo)
        .on_success { |value| assert_equal(:foo, value) }
        .on_unknown { raise }

      Success
        .new(type: :bar, value: :foo)
        .on_success(:bar) { |value| assert_equal(:foo, value) }
        .on_unknown { raise }
    end

    test '#on_unknown is ignored when a failure hook is called' do
      Failure
        .new(type: :bar, value: :foo)
        .on_failure { |value| assert_equal(:foo, value) }
        .on_unknown { raise }

      Failure
        .new(type: :bar, value: :foo)
        .on_failure(:bar) { |value| assert_equal(:foo, value) }
        .on_unknown { raise }
    end

    test '#on_unknown is called when no other hook is called' do
      number = 0

      Success
        .new(type: :bar, value: :foo)
        .on(:foo) { raise }
        .on_success(:foo) { raise }
        .on_failure { raise }
        .on_unknown { number += 1 }

      Failure
        .new(type: :bar, value: :foo)
        .on(:foo) { raise }
        .on_success { raise }
        .on_unknown { number += 1 }

      assert_equal 2, number
    end

    test '#on_unknown returns the result itself' do
      failure = Failure.new(type: :error, value: 0)

      r1 = failure
           .on_unknown { |value| assert_equal(0, value) }

      r2 = failure
           .on_success { |value| assert_equal(0, value) }
           .on_unknown { |value| assert_equal(0, value) }

      assert_same failure, r1
      assert_same failure, r2

      # --

      success = Success.new(type: :ok, value: 1)

      r3 = success
           .on_unknown { |value| assert_equal(1, value) }

      r4 = success
           .on_failure { |value| assert_equal(1, value) }

      assert_same success, r3
      assert_same success, r4
    end
  end
end
