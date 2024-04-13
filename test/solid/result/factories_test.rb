# frozen_string_literal: true

require 'test_helper'

class Solid::Result::FactoriesTest < Minitest::Test
  test '.Success() wihout a value' do
    result = Solid::Result.Success(:ok)

    assert result.success?(:ok)

    assert_equal :ok, result.type

    assert_nil result.value
  end

  test '.Success() with a value' do
    value = [rand, 1, '1', [], {}].sample

    result = Solid::Result.Success(:ok, value)

    assert result.success?(:ok)

    assert_equal :ok, result.type

    assert_equal value, result.value
  end

  test '.Failure() wihout a value' do
    result = Solid::Result.Failure(:err)

    assert result.failure?(:err)

    assert_equal :err, result.type

    assert_nil result.value
  end

  test '.Failure() with a value' do
    value = [rand, 2, '2', [], {}].sample

    result = Solid::Result.Failure(:err, value)

    assert result.failure?(:err)

    assert_equal :err, result.type

    assert_equal value, result.value
  end
end
