# frozen_string_literal: true

require 'test_helper'

class BCDD::Result
  class ConfigurationTest < Minitest::Test
    test '.configuration' do
      config_instance = Config.send(:new)
      event_logs_config_instance = EventLogs::Config.send(:new)

      BCDD::Result.expects(:config).twice.returns(config_instance)
      EventLogs::Config.expects(:instance).returns(event_logs_config_instance)

      refute_predicate(config_instance, :frozen?)

      refute(config_instance.addon.enabled?(:continue))

      BCDD::Result.configuration do |config|
        assert_same(config_instance, config)

        config.addon.enable!(:continue)

        refute_predicate(config_instance, :frozen?)
      end

      assert(config_instance.addon.enabled?(:continue))

      assert_predicate(config_instance, :frozen?)
    end

    test 'configuration freezing' do
      String(ENV.fetch('TEST_CONFIG_FREEZING', nil)).match?(/true/i) or return

      refute(BCDD::Result.config.addon.enabled?(:continue))

      BCDD::Result.configuration do |config|
        assert_same(BCDD::Result.config, config)

        config.addon.enable!(:continue)

        refute_predicate(BCDD::Result.config, :frozen?)
      end

      assert(BCDD::Result.config.addon.enabled?(:continue))

      assert_predicate(BCDD::Result.config, :frozen?)

      assert_predicate(BCDD::Result.config.and_then!, :frozen?)

      assert_predicate(BCDD::Result.config.event_logs, :frozen?)
    end
  end
end
