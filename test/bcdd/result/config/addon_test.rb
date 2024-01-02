# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::Config
  class AddonTest < Minitest::Test
    AFFECTS = [
      'BCDD::Result.mixin',
      'BCDD::Result::Context.mixin',
      'BCDD::Result::Expectations.mixin',
      'BCDD::Result::Context::Expectations.mixin'
    ].freeze

    test 'the switcher' do
      config = BCDD::Result.config.addon

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
