# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::Config
  class AddonTest < Minitest::Test
    test 'the switcher' do
      config = BCDD::Result.config.addon

      assert_instance_of(Switcher, config)

      assert_equal(
        {
          continue: {
            enabled: false,
            affects: [
              'BCDD::Result',
              'BCDD::Result::Context',
              'BCDD::Result::Expectations',
              'BCDD::Result::Context::Expectations'
            ]
          }
        },
        config.options
      )
    end
  end
end
