# frozen_string_literal: true

require 'test_helper'

class Solid::Result::Config
  class AddonTest < Minitest::Test
    AFFECTS = [
      'Solid::Result.mixin',
      'Solid::Output.mixin',
      'Solid::Result::Expectations.mixin',
      'Solid::Output::Expectations.mixin'
    ].freeze

    test 'the switcher' do
      config = Solid::Result.config.addon

      assert_instance_of(Switcher, config)

      assert_equal(
        {
          continue: { enabled: false, affects: AFFECTS },
          given: { enabled: true, affects: AFFECTS }
        },
        config.options
      )
    end
  end
end
