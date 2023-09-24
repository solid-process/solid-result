# frozen_string_literal: true

require 'test_helper'

class BCDD::Result
  class OnSuccessHookTest < Minitest::Test
    test '#on_success returns the result itself' do
      result = Success.new(type: :okay, value: 1)

      r1 = result
           .on_success(:okay) { |value| assert_equal(1, value) }

      r2 = result
           .on_success(:okay) { |value| assert_equal(1, value) }
           .on_success(:okay) { |value| assert_equal(1, value) }

      assert_same result, r1
      assert_same result, r2
    end

    test '#on_success without receving types/arguments' do
      number = 0

      result = Success.new(type: :okay, value: 1)

      result
        .on_success { |value| number += value }
        .on_success { |value| number += value }

      result.on_success { |value| number += value }

      assert_equal 3, number
    end

    test '#on_success with a single type' do
      number = 0

      result = Success.new(type: :okay, value: 1)

      result
        .on_success { |value| number += value }
        .on_success(:okay) { |value| number += value }
        .on_success(:okay) { |value| number += value }
        .on_success(:wont_count) { |value| number += value }
        .on_success { |value| number += value }

      assert_equal 4, number
    end

    test '#on_success with multiple types' do
      number = 0

      result = Success.new(type: :ok, value: 1)

      result
        .on_success(:okay, :ok) { |value| number += value }
        .on_success { |value| number += value }
        .on_success(:okay) { |value| number += value }
        .on_success(:ok, :wont_count) { |value| number += value }
        .on_success(:wont_count) { |value| number += value }
        .on_success { |value| number += value }

      assert_equal 4, number
    end

    test '#on_success without matching types' do
      number = 0

      result = Success.new(type: :ok, value: 1)

      result
        .on_success(:yes) { |value| number += value }
        .on_success(:okay) { |value| number += value }

      assert_equal 0, number
    end

    test '#on_success is ignored by failures' do
      number = 0

      result = Failure.new(type: :err, value: 0)

      result
        .on_success { |value| number += value }
        .on_success(:err) { |value| number += value }

      assert_equal 0, number
    end
  end
end
