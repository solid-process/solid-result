# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::Config
  class PatternMatchingTest < Minitest::Test
    test 'the switcher' do
      config = BCDD::Result.config.pattern_matching

      assert_instance_of(Switcher, config)

      assert_equal(
        {
          nil_as_valid_value_checking: {
            enabled: false,
            affects: [
              'BCDD::Result::Expectations',
              'BCDD::Context::Expectations'
            ]
          }
        },
        config.options
      )
    end
  end
end
