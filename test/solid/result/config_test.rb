# frozen_string_literal: true

require 'test_helper'

class Solid::Result::Config
  class Test < Minitest::Test
    test '.instance' do
      assert Solid::Result::Config.instance.is_a?(Solid::Result::Config)

      assert_same(Solid::Result::Config.instance, Solid::Result.config)
    end

    test '#addon' do
      assert_respond_to(Solid::Result.config, :addon)
    end

    test '#feature' do
      assert_respond_to(Solid::Result.config, :feature)
    end

    test '#constant_alias' do
      assert_respond_to(Solid::Result.config, :constant_alias)
    end

    test '#pattern_matching' do
      assert_respond_to(Solid::Result.config, :pattern_matching)
    end

    test '#options' do
      assert_instance_of(Hash, Solid::Result.config.options)

      assert_equal(
        %i[
          addon
          constant_alias
          feature
          pattern_matching
        ],
        Solid::Result.config.options.keys.sort
      )

      Solid::Result.config.options.each_value do |switcher|
        assert_instance_of(Switcher, switcher)
      end
    end

    test '#to_h' do
      config_values = Solid::Result.config.to_h

      assert_equal({ continue: false, given: true }, config_values[:addon])
      assert_equal({ expectations: true, event_logs: true, and_then!: false }, config_values[:feature])
      assert_equal({ nil_as_valid_value_checking: false }, config_values[:pattern_matching])
      assert_equal({ 'Result' => false }, config_values[:constant_alias])

      Solid::Result.config.options.each do |key, switcher|
        assert_equal(switcher.to_h, config_values[key])
      end
    end

    test '#inspect' do
      assert_equal(
        '#<Solid::Result::Config ' \
        'options=[:addon, :constant_alias, :feature, :pattern_matching] ' \
        'and_then!={:default_method_name_to_call=>:call}>',
        Solid::Result.config.inspect
      )
    end

    test '#freeze' do
      event_logs_config_instance = Solid::Result::EventLogs::Config.send(:new)

      Solid::Result::EventLogs::Config.expects(:instance).returns(event_logs_config_instance)

      instance = Solid::Result::Config.send(:new)

      assert_instance_of(Solid::Result::Config, instance)

      refute_same(Solid::Result::Config.instance, instance)

      instance.freeze

      assert_predicate(instance, :frozen?)
      assert_predicate(instance.addon, :frozen?)
      assert_predicate(instance.feature, :frozen?)
      assert_predicate(instance.constant_alias, :frozen?)
      assert_predicate(instance.pattern_matching, :frozen?)
      assert_predicate(event_logs_config_instance, :frozen?)
    end
  end
end
