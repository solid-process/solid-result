# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::Config
  class AddonContinueTest < Minitest::Test
    test 'the side effects' do
      class1 = Class.new do
        include BCDD::Result.mixin

        def call
          Continue('the method Continue does not exist as the config is disabled')
        end
      end

      error1 = assert_raises(NoMethodError) { class1.new.call }

      assert_match(/undefined method.+Continue/, error1.message)

      BCDD::Result.config.addon.enable!(:continue)

      class2 = Class.new do
        include BCDD::Result.mixin

        def call
          Continue('the method Continue now exists as the config is enabled by default')
        end
      end

      assert_equal(
        'the method Continue now exists as the config is enabled by default',
        class2.new.call.value
      )
    ensure
      BCDD::Result.config.addon.disable!(:continue)

      class3 = Class.new do
        include BCDD::Result.mixin

        def call
          Continue('the error is raised again as the config is disabled by default')
        end
      end

      error2 = assert_raises(NoMethodError) { class3.new.call }

      assert_match(/undefined method.+Continue/, error2.message)
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
          Continue("this method won't exist as the default config was overwritten")
        end
      end

      class4 = Class.new do
        include BCDD::Result::Context::Expectations.mixin(config: { addon: { continue: false } })

        def call
          Continue("this method won't exist as the default config was overwritten")
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
