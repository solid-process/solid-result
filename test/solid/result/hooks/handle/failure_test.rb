# frozen_string_literal: true

require 'test_helper'

class Solid::Result
  class HandleFailureTest < Minitest::Test
    test '#handle returns nil when there is no handler for the result' do
      result = Failure.new(type: :foo, value: :bar)

      outcome = result.handle do |on|
        on.failure(:bar) { 1 }
        on.success { 0 }
        on[:baz] { 2 }
      end

      assert_nil outcome
    end

    test '#handle returns the value of the block when a handler matches the result type' do
      result = Failure.new(type: :foo, value: :bar)

      outcome1 = result.handle do |on|
        on.success(:foo) { 0 }
        on.failure { 1 }
      end

      assert_equal 1, outcome1

      outcome2 = result.handle do |on|
        on.success { 0 }
        on[:foo] { 2 }
      end

      assert_equal 2, outcome2

      outcome3 = result.handle do |on|
        on.type(:foo) { 3 }
        on.success { 0 }
      end

      assert_equal 3, outcome3
    end

    test '#handle matches even when the type is missing' do
      result = Failure.new(type: :foo, value: :bar)

      outcome = result.handle do |on|
        on[:baz] { 3 }
        on.failure { 2 }
        on.failure(:foo) { 1 }
        on.success { 0 }
      end

      assert_equal 2, outcome
    end

    test '#handle raises an error when type handler does not receive an argument' do
      result = Failure.new(type: :foo, value: :bar)

      error = assert_raises(Solid::Result::Error::MissingTypeArgument) do
        result.handle do |on|
          on.type { 1 }
        end
      end

      assert_equal(
        'A type (argument) is required to invoke the #on/#on_type method',
        error.message
      )
    end
  end
end
