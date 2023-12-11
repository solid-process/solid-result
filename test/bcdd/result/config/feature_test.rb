# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::Config
  class FeatureInstanceTest < Minitest::Test
    test 'the switcher' do
      config = BCDD::Result.config.feature

      assert_instance_of(Switcher, config)

      assert_equal(
        {
          expectations: {
            enabled: true,
            affects: [
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
