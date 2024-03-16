# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::Config
  class AddonGivenTest < Minitest::Test
    test 'the side effects' do
      BCDD::Result.config.addon.disable!(:given)

      class1a = Class.new do
        include BCDD::Result.mixin

        def call
          Given("this method won't exist as the default config is disabled")
        end
      end

      class2a = Class.new do
        include BCDD::Result::Expectations.mixin

        def call
          Given("this method won't exist as the default config is disabled")
        end
      end

      class3a = Class.new do
        include BCDD::Context.mixin

        def call
          Given(msg: "this method won't exist as the default config is disabled")
        end
      end

      class4a = Class.new do
        include BCDD::Context::Expectations.mixin

        def call
          Given(msg: "this method won't exist as the default config is disabled")
        end
      end

      error1a = assert_raises(NoMethodError) { class1a.new.call }
      error2a = assert_raises(NoMethodError) { class2a.new.call }
      error3a = assert_raises(NoMethodError) { class3a.new.call }
      error4a = assert_raises(NoMethodError) { class4a.new.call }

      assert_match(/undefined method.+Given/, error1a.message)
      assert_match(/undefined method.+Given/, error2a.message)
      assert_match(/undefined method.+Given/, error3a.message)
      assert_match(/undefined method.+Given/, error4a.message)

      BCDD::Result.config.addon.enable!(:given)

      class1b = Class.new do
        include BCDD::Result.mixin

        def call
          Given('this method will exist as the config is enabled by default')
        end
      end

      class2b = Class.new do
        include BCDD::Result::Expectations.mixin

        def call
          Given('this method will exist as the config is enabled by default')
        end
      end

      class3b = Class.new do
        include BCDD::Context.mixin

        def call
          part1 = { part1: 'this method will exist' }
          part2 = { part2: 'as the config is enabled by default' }

          Given(part1, part2)
            .and_then { |data| Given(msg: "#{data[:part1]} #{data[:part2]}") }
        end
      end

      class4b = Class.new do
        include BCDD::Context::Expectations.mixin

        def call
          part1 = { part1: 'this method will exist' }
          part2 = { part2: 'as the config is enabled by default' }

          Given(part1, part2)
            .and_then { |data| Given(msg: "#{data[:part1]} #{data[:part2]}") }
        end
      end

      result1b = class1b.new.call
      result2b = class2b.new.call
      result3b = class3b.new.call
      result4b = class4b.new.call

      assert_equal('this method will exist as the config is enabled by default', result1b.value)
      assert_equal('this method will exist as the config is enabled by default', result2b.value)
      assert_equal('this method will exist as the config is enabled by default', result3b.value[:msg])
      assert_equal('this method will exist as the config is enabled by default', result4b.value[:msg])

      assert(result1b.success?(:_given_))
      assert(result2b.success?(:_given_))
      assert(result3b.success?(:_given_) && result3b.value.keys == [:msg])
      assert(result4b.success?(:_given_) && result4b.value.keys == [:msg])
    end

    test 'the overwriting of the default config' do
      BCDD::Result.config.addon.enable!(:given)

      class1 = Class.new do
        include BCDD::Result.mixin(config: { addon: { given: false } })

        def call
          Given("this method won't exist as the default config was overwritten")
        end
      end

      class2 = Class.new do
        include BCDD::Result::Expectations.mixin(config: { addon: { given: false } })

        def call
          Given("this method won't exist as the default config was overwritten")
        end
      end

      class3 = Class.new do
        include BCDD::Context.mixin(config: { addon: { given: false } })

        def call
          Given(msg: "this method won't exist as the default config was overwritten")
        end
      end

      class4 = Class.new do
        include BCDD::Context::Expectations.mixin(config: { addon: { given: false } })

        def call
          Given(msg: "this method won't exist as the default config was overwritten")
        end
      end

      error1 = assert_raises(NoMethodError) { class1.new.call }
      error2 = assert_raises(NoMethodError) { class2.new.call }
      error3 = assert_raises(NoMethodError) { class3.new.call }
      error4 = assert_raises(NoMethodError) { class4.new.call }

      assert_match(/undefined method.+Given/, error1.message)
      assert_match(/undefined method.+Given/, error2.message)
      assert_match(/undefined method.+Given/, error3.message)
      assert_match(/undefined method.+Given/, error4.message)
    end
  end
end
