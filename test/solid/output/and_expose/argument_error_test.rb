# frozen_string_literal: true

require 'test_helper'

module Solid
  class OutputAndExposeArgumentErrorTest < Minitest::Test
    class NotAnArray
      include Solid::Output.mixin

      def call
        Success(:ok, number: 1)
          .and_expose(:ok, nil)
      end
    end

    class EmptyArray
      include Solid::Output.mixin

      def call
        Success(:ok, number: 1)
          .and_expose(:ok, [])
      end
    end

    class AnyKeyAreNotSymbol
      include Solid::Output.mixin

      def call
        Success(:ok, number: 1)
          .and_expose(:ok, [:number, 'number'])
      end
    end

    test '#and_expose raises ArgumentError when keys is not an Array' do
      err = assert_raises(ArgumentError) { NotAnArray.new.call }

      assert_equal(
        'keys must be an Array of Symbols',
        err.message
      )
    end

    test '#and_expose raises ArgumentError when keys is an empty Array' do
      err = assert_raises(ArgumentError) { EmptyArray.new.call }

      assert_equal(
        'keys must be an Array of Symbols',
        err.message
      )
    end

    test '#and_expose raises ArgumentError when any key is not a Symbol' do
      err = assert_raises(ArgumentError) { AnyKeyAreNotSymbol.new.call }

      assert_equal(
        'keys must be an Array of Symbols',
        err.message
      )
    end
  end
end
