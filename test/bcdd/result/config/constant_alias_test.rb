# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::Config
  class ConstantAliasTest < Minitest::Test
    test 'the switcher' do
      config = BCDD::Result.config.constant_alias

      assert_instance_of(Switcher, config)

      assert_equal(
        { 'Result' => { enabled: false, affects: ['Object'] } },
        config.options
      )
    end
  end
end
