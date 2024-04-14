# frozen_string_literal: true

require 'test_helper'

class Solid::Result::Config
  class PatternMatchingNilAsAValidValueCheckingTest < Minitest::Test
    test 'the side effects' do
      is_numeric = ->(v) do
        case v
        in Numeric then true
        end

        nil
      end

      is_hash_numeric = ->(v) do
        case v
        in { number: Numeric } then true
        end

        nil
      end

      class1a = Class.new do
        include Solid::Result::Expectations.mixin(success: { ok: is_numeric })

        def call; Success(:ok, 1); end
      end

      class1b = Class.new
      class1b.const_set(:Result, Solid::Result::Expectations.new(success: { ok: is_numeric }))
      class1b.class_eval { def call; self.class.const_get(:Result, false)::Success(:ok, 1); end }

      class1c = Class.new do
        include Solid::Output::Expectations.mixin(success: { ok: is_hash_numeric })

        def call; Success(:ok, number: 1); end
      end

      class1d = Class.new
      class1d.const_set(:Result, Solid::Output::Expectations.new(success: { ok: is_hash_numeric }))
      class1d.class_eval { def call; self.class.const_get(:Result, false)::Success(:ok, number: 1); end }

      assert_raises(Solid::Result::Contract::Error::UnexpectedValue) { class1a.new.call }
      assert_raises(Solid::Result::Contract::Error::UnexpectedValue) { class1b.new.call }
      assert_raises(Solid::Result::Contract::Error::UnexpectedValue) { class1c.new.call }
      assert_raises(Solid::Result::Contract::Error::UnexpectedValue) { class1d.new.call }

      assert_raises(Solid::Result::Contract::Error::UnexpectedValue) { class1a::Result::Success(:ok, 1) }
      assert_raises(Solid::Result::Contract::Error::UnexpectedValue) { class1b::Result::Success(:ok, 1) }
      assert_raises(Solid::Result::Contract::Error::UnexpectedValue) { class1c::Result::Success(:ok, number: 1) }
      assert_raises(Solid::Result::Contract::Error::UnexpectedValue) { class1d::Result::Success(:ok, number: 1) }

      Solid::Result.config.pattern_matching.enable!(:nil_as_valid_value_checking)

      class2a = Class.new do
        include Solid::Result::Expectations.mixin(success: { ok: is_numeric })

        def call; Success(:ok, 1); end
      end

      class2b = Class.new
      class2b.const_set(:Result, Solid::Result::Expectations.new(success: { ok: is_numeric }))
      class2b.class_eval { def call; self.class.const_get(:Result, false)::Success(:ok, 1); end }

      class2c = Class.new do
        include Solid::Output::Expectations.mixin(success: { ok: is_hash_numeric })

        def call; Success(:ok, number: 1); end
      end

      class2d = Class.new
      class2d.const_set(:Result, Solid::Output::Expectations.new(success: { ok: is_hash_numeric }))
      class2d.class_eval { def call; self.class.const_get(:Result, false)::Success(:ok, number: 1); end }

      assert(class2a.new.call.then { _1.success?(:ok) && _1.value == 1 })
      assert(class2b.new.call.then { _1.success?(:ok) && _1.value == 1 })
      assert(class2c.new.call.then { _1.success?(:ok) && _1.value == { number: 1 } })
      assert(class2d.new.call.then { _1.success?(:ok) && _1.value == { number: 1 } })

      assert(class2a::Result::Success(:ok, 1).then { _1.success?(:ok) && _1.value == 1 })
      assert(class2b::Result::Success(:ok, 1).then { _1.success?(:ok) && _1.value == 1 })
      assert(class2c::Result::Success(:ok, number: 1).then { _1.success?(:ok) && _1.value == { number: 1 } })
      assert(class2d::Result::Success(:ok, number: 1).then { _1.success?(:ok) && _1.value == { number: 1 } })

      assert_raises(Solid::Result::Contract::Error::UnexpectedValue) { class2a::Result::Success(:ok, '1') }
      assert_raises(Solid::Result::Contract::Error::UnexpectedValue) { class2b::Result::Success(:ok, '1') }
      assert_raises(Solid::Result::Contract::Error::UnexpectedValue) { class2c::Result::Success(:ok, number: '1') }
      assert_raises(Solid::Result::Contract::Error::UnexpectedValue) { class2d::Result::Success(:ok, number: '1') }
    ensure
      Solid::Result.config.pattern_matching.disable!(:nil_as_valid_value_checking)

      class3a = Class.new do
        include Solid::Result::Expectations.mixin(success: { ok: is_numeric })

        def call; Success(:ok, 1); end
      end

      class3b = Class.new
      class3b.const_set(:Result, Solid::Result::Expectations.new(success: { ok: is_numeric }))
      class3b.class_eval { def call; self.class.const_get(:Result, false)::Success(:ok, 1); end }

      class3c = Class.new do
        include Solid::Output::Expectations.mixin(success: { ok: is_hash_numeric })

        def call; Success(:ok, number: 1); end
      end

      class3d = Class.new
      class3d.const_set(:Result, Solid::Output::Expectations.new(success: { ok: is_hash_numeric }))
      class3d.class_eval { def call; self.class.const_get(:Result, false)::Success(:ok, number: 1); end }

      assert_raises(Solid::Result::Contract::Error::UnexpectedValue) { class3a.new.call }
      assert_raises(Solid::Result::Contract::Error::UnexpectedValue) { class3b.new.call }
      assert_raises(Solid::Result::Contract::Error::UnexpectedValue) { class3c.new.call }
      assert_raises(Solid::Result::Contract::Error::UnexpectedValue) { class3d.new.call }

      assert_raises(Solid::Result::Contract::Error::UnexpectedValue) { class3a::Result::Success(:ok, 1) }
      assert_raises(Solid::Result::Contract::Error::UnexpectedValue) { class3b::Result::Success(:ok, 1) }
      assert_raises(Solid::Result::Contract::Error::UnexpectedValue) { class3c::Result::Success(:ok, number: 1) }
      assert_raises(Solid::Result::Contract::Error::UnexpectedValue) { class3d::Result::Success(:ok, number: 1) }
    end

    test 'the overwriting of the default config' do
      Solid::Result.config.pattern_matching.enable!(:nil_as_valid_value_checking)

      is_numeric = ->(v) do
        case v
        in Numeric then true
        end

        nil
      end

      is_hash_numeric = ->(v) do
        case v
        in { number: Numeric } then true
        end

        nil
      end

      class1 = Class.new do
        include Solid::Result::Expectations.mixin(
          config: { pattern_matching: { nil_as_valid_value_checking: false } },
          success: { ok: is_numeric }
        )

        def call; Success(:ok, 1); end
      end

      class2 = Class.new
      class2.const_set(
        :Result,
        Solid::Result::Expectations.new(
          config: { pattern_matching: { nil_as_valid_value_checking: false } },
          success: { ok: is_numeric }
        )
      )
      class2.class_eval { def call; self.class.const_get(:Result, false)::Success(:ok, 1); end }

      class3 = Class.new do
        include Solid::Output::Expectations.mixin(
          config: { pattern_matching: { nil_as_valid_value_checking: false } },
          success: { ok: is_hash_numeric }
        )

        def call; Success(:ok, number: 1); end
      end

      class4 = Class.new
      class4.const_set(
        :Result,
        Solid::Output::Expectations.new(
          config: { pattern_matching: { nil_as_valid_value_checking: false } },
          success: { ok: is_hash_numeric }
        )
      )
      class4.class_eval { def call; self.class.const_get(:Result, false)::Success(:ok, number: 1); end }

      assert_raises(Solid::Result::Contract::Error::UnexpectedValue) { class1.new.call }
      assert_raises(Solid::Result::Contract::Error::UnexpectedValue) { class2.new.call }
      assert_raises(Solid::Result::Contract::Error::UnexpectedValue) { class3.new.call }
      assert_raises(Solid::Result::Contract::Error::UnexpectedValue) { class4.new.call }
    ensure
      Solid::Result.config.pattern_matching.disable!(:nil_as_valid_value_checking)
    end
  end
end
