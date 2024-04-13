# frozen_string_literal: true

require 'test_helper'

class Solid::Result::Config
  class FeatureInstanceTest < Minitest::Test
    test 'the switcher' do
      config = Solid::Result.config.feature

      assert_instance_of(Switcher, config)

      assert_equal(
        {
          expectations: {
            enabled: true,
            affects: ['Solid::Result::Expectations', 'Solid::Output::Expectations']
          },
          event_logs: { enabled: true, affects: %w[
            Solid::Result Solid::Output Solid::Result::Expectations Solid::Output::Expectations
          ] },
          and_then!: { enabled: false, affects: %w[
            Solid::Result Solid::Output Solid::Result::Expectations Solid::Output::Expectations
          ] }
        },
        config.options
      )
    end
  end
end
