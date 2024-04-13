# frozen_string_literal: true

require 'test_helper'

class Solid::Result
  class SuccessTest < Minitest::Test
    test 'is a Solid::Result' do
      assert Success < Solid::Result
    end

    test 'is a Solid::Success' do
      assert Success < Solid::Success
    end

    test '#terminal?' do
      result = Success.new(type: :ok, value: nil)

      refute_predicate result, :terminal?
    end

    test '#success? without receiving a type/argument' do
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

    test '#type?' do
      result = Success.new(type: :good, value: nil)

      assert result.type?(:good)

      refute result.type?(:ok)
    end

    test '#is?' do
      result = Success.new(type: :good, value: nil)

      assert result.is?(:good)

      refute result.is?(:ok)
    end

    test '#method_missing' do
      result = Success.new(type: :good, value: nil)

      assert_predicate result, :good?

      refute_predicate result, :bad?

      assert_raises(NoMethodError) { result.good }
    end

    test '#respond_to_missing?' do
      result = Success.new(type: :good, value: nil)

      assert_respond_to result, :good?

      assert_respond_to result, :bad?
    end

    test '#value_or' do
      result = Success.new(type: :ok, value: 1)

      assert_equal(1, result.value_or { 0 })
    end

    test '#inspect' do
      result = Success.new(type: :ok, value: 2)

      assert_equal '#<Solid::Result::Success type=:ok value=2>', result.inspect
    end
  end
end
