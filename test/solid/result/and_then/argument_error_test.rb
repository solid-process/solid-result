# frozen_string_literal: true

require 'test_helper'

class Solid::Result
  class AndThenArgumentErrorTest < Minitest::Test
    module SomeModule
      extend Solid::Result.mixin

      def self.call(arg1, arg2)
        Success(:ok, arg1 + arg2)
          .and_then(:some_method_name) { :method_name_and_block_are_not_allowed }
      end
    end

    test 'raises ArgumentError when the method name and block are both given' do
      error = assert_raises(ArgumentError) { SomeModule.call(1, 2) }

      assert_equal(
        'method_name and block are mutually exclusive',
        error.message
      )
    end
  end
end
