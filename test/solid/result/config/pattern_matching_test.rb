# frozen_string_literal: true

require 'test_helper'

class Solid::Result::Config
  class PatternMatchingTest < Minitest::Test
    test 'the switcher' do
      config = Solid::Result.config.pattern_matching

      assert_instance_of(Switcher, config)

      assert_equal(
        {
          nil_as_valid_value_checking: {
            enabled: false,
            affects: [
              'Solid::Result::Expectations',
              'Solid::Output::Expectations'
            ]
          }
        },
        config.options
      )
    end
  end
end
