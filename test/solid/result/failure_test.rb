# frozen_string_literal: true

require 'test_helper'

class Solid::Result
  class FailureTest < Minitest::Test
    test 'is a Solid::Result' do
      assert Failure < Solid::Result
    end

    test 'is a Solid::Failure' do
      assert Failure < Solid::Failure
    end

    test '#terminal?' do
      result = Failure.new(type: :err, value: nil)

      assert_predicate result, :terminal?
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

    test '#type?' do
      result = Failure.new(type: :bad, value: nil)

      assert result.type?(:bad)

      refute result.type?(:err)
    end

    test '#is?' do
      result = Failure.new(type: :bad, value: nil)

      assert result.is?(:bad)

      refute result.is?(:err)
    end

    test '#method_missing' do
      result = Failure.new(type: :bad, value: nil)

      assert_respond_to result, :good?

      assert_respond_to result, :bad?
    end

    test '#respond_to_missing?' do
      result = Failure.new(type: :err, value: nil)

      assert_predicate result, :err?

      refute_predicate result, :ok?

      assert_raises(NoMethodError) { result.ok }
    end

    test '#value_or' do
      result = Failure.new(type: :err, value: nil)

      assert_equal(0, result.value_or { 0 })
    end

    test '#inspect' do
      result = Failure.new(type: :err, value: 2)

      assert_equal '#<Solid::Result::Failure type=:err value=2>', result.inspect
    end
  end
end
