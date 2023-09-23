# frozen_string_literal: true

require 'test_helper'

module BCDD::Result
  class BaseTest < Minitest::Test
    const_set(:Abstract, Class.new(Base))

    test 'is a private constant' do
      error = assert_raises(NameError) { BCDD::Result::Base }

      assert_equal 'private constant BCDD::Result::Base referenced', error.message
    end

    test '#initialize errors' do
      error1 = assert_raises(ArgumentError) { Abstract.new(type: :ok) }
      error2 = assert_raises(ArgumentError) { Abstract.new(value: 1) }
      error3 = assert_raises(ArgumentError) { Abstract.new }

      assert_equal 'missing keyword: :value', error1.message

      assert_equal 'missing keyword: :type', error2.message

      assert_equal 'missing keywords: :type, :value', error3.message
    end

    test '#value' do
      assert_equal 1, Abstract.new(type: :ok, value: 1).value

      assert_nil Abstract.new(type: :ok, value: nil).value
    end

    test '#type' do
      assert_equal :ok, Abstract.new(type: :ok, value: 1).type
      assert_equal :yes, Abstract.new(type: :yes, value: nil).type

      assert_equal :err, Abstract.new(type: :err, value: 0).type
      assert_equal :no, Abstract.new(type: :no, value: nil).type
    end

    test '#success?' do
      result = Abstract.new(type: :ok, value: 1)

      assert_raises(BCDD::Result::Error::NotImplemented) { result.success? }

      assert_raises(BCDD::Result::Error::NotImplemented) { result.success?(:ok) }
    end

    test '#failure?' do
      result = Abstract.new(type: :err, value: 0)

      assert_raises(BCDD::Result::Error::NotImplemented) { result.failure? }

      assert_raises(BCDD::Result::Error::NotImplemented) { result.failure?(:err) }
    end

    test '#value_or' do
      result = Abstract.new(type: :ok, value: 1)

      assert_raises(BCDD::Result::Error::NotImplemented) { result.value_or { 0 } }
    end

    test '#==' do
      result = Abstract.new(type: :ok, value: 2)

      assert_equal result, Abstract.new(type: :ok, value: 2)

      refute_equal result, Abstract.new(type: :ok, value: 3)
      refute_equal result, Abstract.new(type: :yes, value: 2)
    end

    test '#eql?' do
      result = Abstract.new(type: :ok, value: 2)

      assert result.eql?(Abstract.new(type: :ok, value: 2))

      refute result.eql?(Abstract.new(type: :ok, value: 3))
      refute result.eql?(Abstract.new(type: :yes, value: 2))
    end

    test '#hash' do
      result = Abstract.new(type: :ok, value: 2)

      assert_equal result.hash, Abstract.new(type: :ok, value: 2).hash

      refute_equal result.hash, Abstract.new(type: :ok, value: 3).hash
      refute_equal result.hash, Abstract.new(type: :yes, value: 2).hash
    end

    test '#inspect' do
      result = Abstract.new(type: :ok, value: 2)

      assert_equal "#<#{Abstract.name} type=:ok value=2>", result.inspect
    end
  end
end
