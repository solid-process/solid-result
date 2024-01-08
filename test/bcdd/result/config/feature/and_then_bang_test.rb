# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::Config
  class FeatureAndThenBangTest < Minitest::Test
    class AddR
      include BCDD::Result.mixin

      def call(arg1, arg2)
        Success(:ok, arg1 + arg2)
      end
    end

    AddR1 = ->(value) { AddR.new.call(value, 1) }

    module AddR2
      def self.call(value)
        AddR.new.call(value, 2)
      end
    end

    module AddR3
      def self.perform(value)
        AddR.new.call(value, 3)
      end
    end

    class AddC
      include BCDD::Result::Context.mixin

      def call(number1:, number2:)
        Success(:ok, number: number1 + number2)
      end
    end

    AddC1 = ->(number:) { AddC.new.call(number1: number, number2: 1) }

    module AddC2
      def self.call(number:)
        AddC.new.call(number1: number, number2: 2)
      end
    end

    module AddC3
      def self.perform(number:)
        AddC.new.call(number1: number, number2: 3)
      end
    end

    test 'the side effects' do
      BCDD::Result.config.feature.enable!(:and_then!)

      result1 =
        AddR1[1]
          .and_then!(AddR2)
          .and_then!(AddR3, _call: :perform)
          .and_then!(AddR1)

      result2 =
        AddC1[number: 2]
          .and_then!(AddC2)
          .and_then!(AddC3, _call: :perform)
          .and_then!(AddC1)

      assert(result1.success?(:ok) && result1.value == 8)
      assert(result2.success?(:ok) && result2.value == { number: 9 })

      BCDD::Result.config.feature.disable!(:and_then!)

      expected_error =
        'You cannot use #and_then! as the feature is disabled. ' \
        'Please use BCDD::Result.config.feature.enable!(:and_then!) to enable it.'

      assert_raises(BCDD::Result::Error::CallableAndThenDisabled, expected_error) { AddR1.call(1).and_then!(AddR2) }
      assert_raises(BCDD::Result::Error::CallableAndThenDisabled, expected_error) { AddC1[number: 2].and_then!(AddC2) }
    ensure
      BCDD::Result.config.feature.disable!(:and_then!)
    end

    test 'the default method name' do
      BCDD::Result.config.feature.enable!(:and_then!)

      BCDD::Result.config.and_then!.default_method_name_to_call = :perform

      result1 = AddR1[1].and_then!(AddR3)

      result2 = AddC1[number: 2].and_then!(AddC3)

      assert(result1.success?(:ok) && result1.value == 5)

      assert(result2.success?(:ok) && result2.value == { number: 6 })
    ensure
      BCDD::Result.config.feature.disable!(:and_then!)

      BCDD::Result.config.and_then!.default_method_name_to_call = :call
    end
  end
end
