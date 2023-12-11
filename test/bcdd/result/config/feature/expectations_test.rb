# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::Config
  class FeatureExpectationsTest < Minitest::Test
    test 'the side effects' do
      class1a = Class.new do
        include BCDD::Result::Expectations.mixin(success: { ok: ::Numeric })

        def call; Success(:ok, '1'); end
      end

      class1b = Class.new
      class1b.const_set(:Result, BCDD::Result::Expectations.new(success: { ok: ::Numeric }))
      class1b.class_eval { def call; self.class.const_get(:Result, false)::Success(:ok, '1'); end }

      class1c = Class.new do
        include BCDD::Result::Context::Expectations.mixin(success: { ok: ->(v) { v[:one] == 1 } })

        def call; Success(:yes, one: 1); end
      end

      class1d = Class.new
      class1d.const_set(:Result, BCDD::Result::Context::Expectations.new(success: { ok: ->(v) { v[:one] == 1 } }))
      class1d.class_eval { def call; self.class.const_get(:Result, false)::Success(:yes, one: 1); end }

      assert_raises(BCDD::Result::Contract::Error::UnexpectedValue) { class1a.new.call }
      assert_raises(BCDD::Result::Contract::Error::UnexpectedValue) { class1b.new.call }
      assert_raises(BCDD::Result::Contract::Error::UnexpectedType) { class1a::Result::Success(:yes, 1) }
      assert_raises(BCDD::Result::Contract::Error::UnexpectedType) { class1b::Result::Success(:yes, 1) }

      assert_raises(BCDD::Result::Contract::Error::UnexpectedValue) { class1c::Result::Success(:ok, one: 2) }
      assert_raises(BCDD::Result::Contract::Error::UnexpectedValue) { class1d::Result::Success(:ok, one: 2) }
      assert_raises(BCDD::Result::Contract::Error::UnexpectedType) { class1c.new.call }
      assert_raises(BCDD::Result::Contract::Error::UnexpectedType) { class1d.new.call }

      BCDD::Result.config.feature.disable!(:expectations)

      class2a = Class.new do
        include BCDD::Result::Expectations.mixin(success: { ok: ::Numeric })

        def call; Success(:ok, '1'); end
      end

      class2b = Class.new
      class2b.const_set(:Result, BCDD::Result::Expectations.new(success: { ok: ::Numeric }))
      class2b.class_eval { def call; self.class.const_get(:Result, false)::Success(:ok, '1'); end }

      class2c = Class.new do
        include BCDD::Result::Context::Expectations.mixin(success: { ok: ->(v) { v[:one] == 1 } })

        def call; Success(:yes, one: 1); end
      end

      class2d = Class.new
      class2d.const_set(:Result, BCDD::Result::Context::Expectations.new(success: { ok: ->(v) { v[:one] == 1 } }))
      class2d.class_eval { def call; self.class.const_get(:Result, false)::Success(:yes, one: 1); end }

      assert(class2a.new.call.then { _1.success?(:ok) && _1.value == '1' })
      assert(class2b.new.call.then { _1.success?(:ok) && _1.value == '1' })
      assert(class2c.new.call.then { _1.success?(:yes) && _1.value == { one: 1 } })
      assert(class2d.new.call.then { _1.success?(:yes) && _1.value == { one: 1 } })

      assert(class2a::Result::Success(:yes, 1).then { _1.success?(:yes) && _1.value == 1 })
      assert(class2b::Result::Success(:yes, 1).then { _1.success?(:yes) && _1.value == 1 })
      assert(class2c::Result::Success(:ok, one: 2).then { _1.success?(:ok) && _1.value == { one: 2 } })
      assert(class2d::Result::Success(:ok, one: 2).then { _1.success?(:ok) && _1.value == { one: 2 } })
    ensure
      BCDD::Result.config.feature.enable!(:expectations)

      class3a = Class.new do
        include BCDD::Result::Expectations.mixin(success: { ok: ::Numeric })

        def call; Success(:ok, '1'); end
      end

      class3b = Class.new
      class3b.const_set(:Result, BCDD::Result::Expectations.new(success: { ok: ::Numeric }))
      class3b.class_eval { def call; self.class.const_get(:Result, false)::Success(:ok, '1'); end }

      class3c = Class.new do
        include BCDD::Result::Context::Expectations.mixin(success: { ok: ->(v) { v[:one] == 1 } })

        def call; Success(:yes, one: 1); end
      end

      class3d = Class.new
      class3d.const_set(:Result, BCDD::Result::Context::Expectations.new(success: { ok: ->(v) { v[:one] == 1 } }))
      class3d.class_eval { def call; self.class.const_get(:Result, false)::Success(:yes, one: 1); end }

      assert_raises(BCDD::Result::Contract::Error::UnexpectedValue) { class3a.new.call }
      assert_raises(BCDD::Result::Contract::Error::UnexpectedValue) { class3b.new.call }
      assert_raises(BCDD::Result::Contract::Error::UnexpectedType) { class3a::Result::Success(:yes, 1) }
      assert_raises(BCDD::Result::Contract::Error::UnexpectedType) { class3b::Result::Success(:yes, 1) }

      assert_raises(BCDD::Result::Contract::Error::UnexpectedValue) { class3c::Result::Success(:ok, one: 2) }
      assert_raises(BCDD::Result::Contract::Error::UnexpectedValue) { class3d::Result::Success(:ok, one: 2) }
      assert_raises(BCDD::Result::Contract::Error::UnexpectedType) { class3c.new.call }
      assert_raises(BCDD::Result::Contract::Error::UnexpectedType) { class3d.new.call }
    end
  end
end
