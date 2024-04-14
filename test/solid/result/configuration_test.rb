# frozen_string_literal: true

require 'test_helper'

class Solid::Result
  class ConfigurationTest < Minitest::Test
    test '.configuration' do
      config_instance = Config.send(:new)
      event_logs_config_instance = EventLogs::Config.send(:new)

      Solid::Result.expects(:config).twice.returns(config_instance)
      EventLogs::Config.expects(:instance).returns(event_logs_config_instance)

      refute_predicate(config_instance, :frozen?)

      refute(config_instance.addon.enabled?(:continue))

      Solid::Result.configuration do |config|
        assert_same(config_instance, config)

        config.addon.enable!(:continue)

        refute_predicate(config_instance, :frozen?)
      end

      assert(config_instance.addon.enabled?(:continue))

      assert_predicate(config_instance, :frozen?)
    end

    test 'configuration freezing' do
      String(ENV.fetch('TEST_CONFIG_FREEZING', nil)).match?(/true/i) or return

      refute(Solid::Result.config.addon.enabled?(:continue))

      Solid::Result.configuration do |config|
        assert_same(Solid::Result.config, config)

        config.addon.enable!(:continue)

        refute_predicate(Solid::Result.config, :frozen?)
      end

      assert(Solid::Result.config.addon.enabled?(:continue))

      assert_predicate(Solid::Result.config, :frozen?)

      assert_predicate(Solid::Result.config.and_then!, :frozen?)

      assert_predicate(Solid::Result.config.event_logs, :frozen?)
    end
  end
end
