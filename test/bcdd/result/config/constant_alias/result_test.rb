# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::Config
  class ConstantAliasResultTest < Minitest::Test
    test 'the side effects' do
      assert_raises(NameError) { ::Result }

      BCDD::Result.config.constant_alias.enable!('Result')

      assert_same(BCDD::Result, ::Result)
    ensure
      BCDD::Result.config.constant_alias.disable!('Result')

      assert_raises(NameError) { ::Result }
    end
  end
end
