# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::Config
  class Test < Minitest::Test
    test '.instance' do
      assert BCDD::Result::Config.instance.is_a?(Singleton)

      assert_same(BCDD::Result::Config.instance, BCDD::Result.config)
    end

    test '#addon' do
      assert_respond_to(BCDD::Result.config, :addon)
    end

    test '#feature' do
      assert_respond_to(BCDD::Result.config, :feature)
    end

    test '#constant_alias' do
      assert_respond_to(BCDD::Result.config, :constant_alias)
    end

    test '#pattern_matching' do
      assert_respond_to(BCDD::Result.config, :pattern_matching)
    end

    test '#options' do
      assert_instance_of(Hash, BCDD::Result.config.options)

      assert_equal(
        %i[
          addon
          constant_alias
          feature
          pattern_matching
        ],
        BCDD::Result.config.options.keys.sort
      )

      BCDD::Result.config.options.each_value do |switcher|
        assert_instance_of(Switcher, switcher)
      end
    end

    test '#to_h' do
      config_values = BCDD::Result.config.to_h

      assert_equal({ continue: false }, config_values[:addon])
      assert_equal({ expectations: true }, config_values[:feature])
      assert_equal({ nil_as_valid_value_checking: false }, config_values[:pattern_matching])
      assert_equal({ 'Result' => false, 'Context' => false, 'BCDD::Context' => false }, config_values[:constant_alias])

      BCDD::Result.config.options.each do |key, switcher|
        assert_equal(switcher.to_h, config_values[key])
      end
    end

    test '#inspect' do
      assert_equal(
        '#<BCDD::Result::Config options=[:addon, :constant_alias, :feature, :pattern_matching]>',
        BCDD::Result.config.inspect
      )
    end

    test '#freeze' do
      instance = BCDD::Result::Config.send(:new)

      assert_instance_of(BCDD::Result::Config, instance)

      refute_same(BCDD::Result::Config.instance, instance)

      instance.freeze

      assert_predicate(instance, :frozen?)
      assert_predicate(instance.addon, :frozen?)
      assert_predicate(instance.feature, :frozen?)
      assert_predicate(instance.constant_alias, :frozen?)
      assert_predicate(instance.pattern_matching, :frozen?)
    end
  end
end
