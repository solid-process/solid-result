# frozen_string_literal: true

require 'test_helper'

module BCDD::Result
  class SuccessTest < Minitest::Test
    test 'is a BCDD::Result::Base' do
      assert Success < Base
    end

    test '#success? without receiving a type' do
      result = Success.new(type: :good, value: nil)

      assert_predicate result, :success?
    end

    test '#success? receiving a type' do
      result = Success.new(type: :good, value: nil)

      assert result.success?(:good)

      refute result.success?(:ok)
    end

    test '#failure? should return false' do
      result = Success.new(type: :ok, value: nil)

      refute_predicate result, :failure?

      refute result.failure?(:ok)
    end

    test '#value_or' do
      result = Success.new(type: :ok, value: 1)

      assert_equal(1, result.value_or { 0 })
    end

    test '#inspect' do
      result = Success.new(type: :ok, value: 2)

      assert_equal '#<BCDD::Result::Success type=:ok value=2>', result.inspect
    end

    test '#data' do
      result = Success.new(type: :okay, value: 1)

      assert_equal 1, result.data

      assert_equal result.method(:value), result.method(:data)
    end

    test '#data_or' do
      result = Success.new(type: :okay, value: 1)

      assert_equal(1, result.data_or { 0 })
    end
  end
end
