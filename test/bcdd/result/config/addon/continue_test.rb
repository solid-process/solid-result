# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::Config
  class AddonContinueTest < Minitest::Test
    test 'the side effects' do
      BCDD::Result.config.addon.disable!(:continue)

      class1a = Class.new do
        include BCDD::Result.mixin

        def call
          Continue("this method won't exist as the default config is disabled")
        end
      end

      class2a = Class.new do
        include BCDD::Result::Expectations.mixin

        def call
          Continue("this method won't exist as the default config is disabled")
        end
      end

      class3a = Class.new do
        include BCDD::Result::Context.mixin

        def call
          Continue(msg: "this method won't exist as the default config is disabled")
        end
      end

      class4a = Class.new do
        include BCDD::Result::Context::Expectations.mixin

        def call
          Continue(msg: "this method won't exist as the default config is disabled")
        end
      end

      error1a = assert_raises(NoMethodError) { class1a.new.call }
      error2a = assert_raises(NoMethodError) { class2a.new.call }
      error3a = assert_raises(NoMethodError) { class3a.new.call }
      error4a = assert_raises(NoMethodError) { class4a.new.call }

      assert_match(/undefined method.+Continue/, error1a.message)
      assert_match(/undefined method.+Continue/, error2a.message)
      assert_match(/undefined method.+Continue/, error3a.message)
      assert_match(/undefined method.+Continue/, error4a.message)

      BCDD::Result.config.addon.enable!(:continue)

      class1b = Class.new do
        include BCDD::Result.mixin

        def call
          Continue('this method will exist as the config is enabled by default')
        end
      end

      class2b = Class.new do
        include BCDD::Result::Expectations.mixin

        def call
          Continue('this method will exist as the config is enabled by default')
        end
      end

      class3b = Class.new do
        include BCDD::Result::Context.mixin

        def call
          Continue(msg: 'this method will exist as the config is enabled by default')
        end
      end

      class4b = Class.new do
        include BCDD::Result::Context::Expectations.mixin

        def call
          Continue(msg: 'this method will exist as the config is enabled by default')
        end
      end

      assert_equal('this method will exist as the config is enabled by default', class1b.new.call.value)
      assert_equal('this method will exist as the config is enabled by default', class2b.new.call.value)
      assert_equal('this method will exist as the config is enabled by default', class3b.new.call.value[:msg])
      assert_equal('this method will exist as the config is enabled by default', class4b.new.call.value[:msg])
    ensure
      BCDD::Result.config.addon.disable!(:continue)

      class1c = Class.new do
        include BCDD::Result.mixin

        def call
          Continue("this method won't exist as the default config is disabled")
        end
      end

      class2c = Class.new do
        include BCDD::Result::Expectations.mixin

        def call
          Continue("this method won't exist as the default config is disabled")
        end
      end

      class3c = Class.new do
        include BCDD::Result::Context.mixin

        def call
          Continue(msg: "this method won't exist as the default config is disabled")
        end
      end

      class4c = Class.new do
        include BCDD::Result::Context::Expectations.mixin

        def call
          Continue(msg: "this method won't exist as the default config is disabled")
        end
      end

      error1c = assert_raises(NoMethodError) { class1c.new.call }
      error2c = assert_raises(NoMethodError) { class2c.new.call }
      error3c = assert_raises(NoMethodError) { class3c.new.call }
      error4c = assert_raises(NoMethodError) { class4c.new.call }

      assert_match(/undefined method.+Continue/, error1c.message)
      assert_match(/undefined method.+Continue/, error2c.message)
      assert_match(/undefined method.+Continue/, error3c.message)
      assert_match(/undefined method.+Continue/, error4c.message)
    end

    test 'the overwriting of the default config' do
      BCDD::Result.config.addon.enable!(:continue)

      class1 = Class.new do
        include BCDD::Result.mixin(config: { addon: { continue: false } })

        def call
          Continue("this method won't exist as the default config was overwritten")
        end
      end

      class2 = Class.new do
        include BCDD::Result::Expectations.mixin(config: { addon: { continue: false } })

        def call
          Continue("this method won't exist as the default config was overwritten")
        end
      end

      class3 = Class.new do
        include BCDD::Result::Context.mixin(config: { addon: { continue: false } })

        def call
          Continue(msg: "this method won't exist as the default config was overwritten")
        end
      end

      class4 = Class.new do
        include BCDD::Result::Context::Expectations.mixin(config: { addon: { continue: false } })

        def call
          Continue(msg: "this method won't exist as the default config was overwritten")
        end
      end

      error1 = assert_raises(NoMethodError) { class1.new.call }
      error2 = assert_raises(NoMethodError) { class2.new.call }
      error3 = assert_raises(NoMethodError) { class3.new.call }
      error4 = assert_raises(NoMethodError) { class4.new.call }

      assert_match(/undefined method.+Continue/, error1.message)
      assert_match(/undefined method.+Continue/, error2.message)
      assert_match(/undefined method.+Continue/, error3.message)
      assert_match(/undefined method.+Continue/, error4.message)
    ensure
      BCDD::Result.config.addon.disable!(:continue)
    end
  end
end
