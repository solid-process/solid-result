# frozen_string_literal: true

require 'test_helper'

module BCDD
  class ResultTest < Minitest::Test
    test '#initialize errors' do
      error1 = assert_raises(ArgumentError) { Result.new(type: :ok) }
      error2 = assert_raises(ArgumentError) { Result.new(value: 1) }
      error3 = assert_raises(ArgumentError) { Result.new }

      assert_equal 'missing keyword: :value', error1.message

      assert_equal 'missing keyword: :type', error2.message

      assert_equal 'missing keywords: :type, :value', error3.message
    end

    test '#value' do
      assert_equal 1, Result.new(type: :ok, value: 1).value

      assert_nil Result.new(type: :ok, value: nil).value
    end

    test '#type' do
      assert_equal :ok, Result.new(type: :ok, value: 1).type
      assert_equal :yes, Result.new(type: :yes, value: nil).type

      assert_equal :err, Result.new(type: :err, value: 0).type
      assert_equal :no, Result.new(type: :no, value: nil).type
    end

    test '#success?' do
      result = Result.new(type: :ok, value: 1)

      assert_raises(BCDD::Result::Error::NotImplemented) { result.success? }

      assert_raises(BCDD::Result::Error::NotImplemented) { result.success?(:ok) }
    end

    test '#failure?' do
      result = Result.new(type: :err, value: 0)

      assert_raises(BCDD::Result::Error::NotImplemented) { result.failure? }

      assert_raises(BCDD::Result::Error::NotImplemented) { result.failure?(:err) }
    end

    test '#value_or' do
      result = Result.new(type: :ok, value: 1)

      assert_raises(BCDD::Result::Error::NotImplemented) { result.value_or { 0 } }
    end

    test '#deconstruct' do
      result = Result.new(type: :ok, value: 1)

      assert_equal([:ok, 1], result.deconstruct)
    end

    test '#deconstruct_keys' do
      result = Result.new(type: :ok, value: 1)

      assert_equal({ unknown: { ok: 1 } }, result.deconstruct_keys([]))
    end

    test '#==' do
      result = Result.new(type: :ok, value: 2)

      assert_equal result, Result.new(type: :ok, value: 2)

      refute_equal result, Result.new(type: :ok, value: 3)
      refute_equal result, Result.new(type: :yes, value: 2)
    end

    test '#eql?' do
      result = Result.new(type: :ok, value: 2)

      assert result.eql?(Result.new(type: :ok, value: 2))

      refute result.eql?(Result.new(type: :ok, value: 3))
      refute result.eql?(Result.new(type: :yes, value: 2))
    end

    test '#hash' do
      result = Result.new(type: :ok, value: 2)

      assert_equal result.hash, Result.new(type: :ok, value: 2).hash

      refute_equal result.hash, Result.new(type: :ok, value: 3).hash
      refute_equal result.hash, Result.new(type: :yes, value: 2).hash
    end

    test '#inspect' do
      result = Result.new(type: :ok, value: 2)

      assert_equal '#<BCDD::Result type=:ok value=2>', result.inspect
    end
  end
end
