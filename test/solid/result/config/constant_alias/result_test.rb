# frozen_string_literal: true

require 'test_helper'

class Solid::Result::Config
  class ConstantAliasResultTest < Minitest::Test
    test 'the side effects (Result)' do
      assert_raises(NameError) { ::Result }

      Solid::Result.config.constant_alias.enable!('Result')

      assert_same(Solid::Result, ::Result)
    ensure
      Solid::Result.config.constant_alias.disable!('Result')

      assert_raises(NameError) { ::Result }
    end
  end
end
