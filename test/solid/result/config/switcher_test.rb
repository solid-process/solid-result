# frozen_string_literal: true

require 'test_helper'

class Solid::Result::Config
  class SwitcherTest < Minitest::Test
    test '#inspect' do
      switcher = Switcher.new(
        options: {
          foo: { default: true, affects: ['foo'] },
          bar: { default: false, affects: ['bar'] }
        }
      )

      assert_equal(
        '#<Solid::Result::Config::Switcher options={:foo=>true, :bar=>false}>',
        switcher.inspect
      )
    end

    test '#freeze' do
      switcher = Switcher.new(
        options: {
          foo: { default: true, affects: ['foo'] },
          bar: { default: false, affects: ['bar'] }
        }
      )

      switcher.freeze

      assert_raises(FrozenError) { switcher.enable!(:foo) }
      assert_raises(FrozenError) { switcher.disable!(:foo) }

      assert switcher.enabled?(:foo)
      refute switcher.enabled?(:bar)

      assert_equal({ foo: true, bar: false }, switcher.to_h)

      assert_equal(
        {
          foo: { enabled: true, affects: ['foo'] },
          bar: { enabled: false, affects: ['bar'] }
        },
        switcher.options
      )
    end

    test '#to_h' do
      switcher = Switcher.new(
        options: {
          foo: { default: true, affects: ['foo'] },
          bar: { default: false, affects: ['bar'] }
        }
      )

      assert_equal(
        { foo: true, bar: false },
        switcher.to_h
      )
    end

    test '#options' do
      switcher = Switcher.new(
        options: {
          foo: { default: true, affects: ['foo'] },
          bar: { default: false, affects: ['bar'] }
        }
      )

      assert_equal(
        {
          foo: { enabled: true, affects: ['foo'] },
          bar: { enabled: false, affects: ['bar'] }
        },
        switcher.options
      )
    end

    test '#enabled?' do
      switcher = Switcher.new(
        options: {
          foo: { default: true, affects: ['foo'] },
          bar: { default: false, affects: ['bar'] }
        }
      )

      assert switcher.enabled?(:foo)
      refute switcher.enabled?(:bar)
    end

    test '#enable! with valid arguments' do
      switcher = Switcher.new(
        options: {
          foo: { default: true, affects: ['foo'] },
          bar: { default: false, affects: ['bar'] }
        }
      )

      switcher.enable!(:bar)

      assert switcher.enabled?(:bar)

      assert_equal({ bar: { enabled: true, affects: ['bar'] } }, switcher.enable!(:bar))
    end

    test '#enable! without arguments' do
      switcher = Switcher.new(
        options: {
          foo: { default: true, affects: ['foo'] },
          bar: { default: false, affects: ['bar'] }
        }
      )

      error = assert_raises(ArgumentError) { switcher.enable! }

      assert_equal('One or more options required. Available options: :foo, :bar', error.message)
    end

    test '#enable! with invalid arguments' do
      switcher = Switcher.new(
        options: {
          foo: { default: true, affects: ['foo'] },
          bar: { default: false, affects: ['bar'] }
        }
      )

      error = assert_raises(ArgumentError) { switcher.enable!(:baz) }

      assert_equal('Invalid option: :baz. Available options: :foo, :bar', error.message)
    end

    test '#disable! with valid arguments' do
      switcher = Switcher.new(
        options: {
          foo: { default: true, affects: ['foo'] },
          bar: { default: false, affects: ['bar'] }
        }
      )

      switcher.disable!(:foo)

      refute switcher.enabled?(:foo)

      assert_equal({ foo: { enabled: false, affects: ['foo'] } }, switcher.disable!(:foo))
    end

    test '#disable! without arguments' do
      switcher = Switcher.new(
        options: {
          foo: { default: true, affects: ['foo'] },
          bar: { default: false, affects: ['bar'] }
        }
      )

      error = assert_raises(ArgumentError) { switcher.disable! }

      assert_equal('One or more options required. Available options: :foo, :bar', error.message)
    end

    test '#disable! with invalid arguments' do
      switcher = Switcher.new(
        options: {
          foo: { default: true, affects: ['foo'] },
          bar: { default: false, affects: ['bar'] }
        }
      )

      error = assert_raises(ArgumentError) { switcher.disable!(:baz) }

      assert_equal('Invalid option: :baz. Available options: :foo, :bar', error.message)
    end
  end
end
