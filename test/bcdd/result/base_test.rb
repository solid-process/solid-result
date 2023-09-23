# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::BaseTest < Minitest::Test
  test '#initialize errors' do
    error1 = assert_raises(ArgumentError) { BCDD::Result.new(type: :ok) }
    error2 = assert_raises(ArgumentError) { BCDD::Result.new(value: 1) }
    error3 = assert_raises(ArgumentError) { BCDD::Result.new }

    assert_equal 'missing keyword: :value', error1.message

    assert_equal 'missing keyword: :type', error2.message

    assert_equal 'missing keywords: :type, :value', error3.message
  end

  test '#value' do
    assert_equal 1, BCDD::Result.new(type: :ok, value: 1).value

    assert_nil BCDD::Result.new(type: :ok, value: nil).value
  end

  test '#type' do
    assert_equal :ok, BCDD::Result.new(type: :ok, value: 1).type
    assert_equal :yes, BCDD::Result.new(type: :yes, value: nil).type

    assert_equal :err, BCDD::Result.new(type: :err, value: 0).type
    assert_equal :no, BCDD::Result.new(type: :no, value: nil).type
  end

  test '#success?' do
    result = BCDD::Result.new(type: :ok, value: 1)

    assert_raises(BCDD::Result::Error::NotImplemented) { result.success? }

    assert_raises(BCDD::Result::Error::NotImplemented) { result.success?(:ok) }
  end

  test '#failure?' do
    result = BCDD::Result.new(type: :err, value: 0)

    assert_raises(BCDD::Result::Error::NotImplemented) { result.failure? }

    assert_raises(BCDD::Result::Error::NotImplemented) { result.failure?(:err) }
  end

  test '#value_or' do
    result = BCDD::Result.new(type: :ok, value: 1)

    assert_raises(NotImplementedError) { result.value_or { 0 } }
  end
end
