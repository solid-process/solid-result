# frozen_string_literal: true

require 'test_helper'

module BCDD::Result
  class FailureTest < Minitest::Test
    test 'is a BCDD::Result::Base' do
      assert Failure < Base
    end

    test '#success? should return false' do
      result = Failure.new(type: :err, value: nil)

      refute_predicate result, :success?

      refute result.success?(:err)
    end

    test '#failure? without receiving a type/argument' do
      result = Failure.new(type: :bad, value: nil)

      assert_predicate result, :failure?
    end

    test '#failure? receiving a type' do
      result = Failure.new(type: :bad, value: nil)

      assert result.failure?(:bad)

      refute result.failure?(:err)
    end

    test '#value_or' do
      result = Failure.new(type: :err, value: nil)

      assert_equal(0, result.value_or { 0 })
    end

    test '#inspect' do
      result = Failure.new(type: :err, value: 2)

      assert_equal '#<BCDD::Result::Failure type=:err value=2>', result.inspect
    end

    test '#data' do
      result = Failure.new(type: :err, value: 3)

      assert_equal 3, result.data

      assert_equal result.method(:value), result.method(:data)
    end

    test '#data_or' do
      result = Failure.new(type: :err, value: nil)

      assert_equal(0, result.data_or { 0 })
    end
  end
end
