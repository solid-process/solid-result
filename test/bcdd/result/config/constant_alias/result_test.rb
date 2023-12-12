# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::Config
  class ConstantAliasResultTest < Minitest::Test
    test 'the side effects (Result)' do
      assert_raises(NameError) { ::Result }

      BCDD::Result.config.constant_alias.enable!('Result')

      assert_same(BCDD::Result, ::Result)
    ensure
      BCDD::Result.config.constant_alias.disable!('Result')

      assert_raises(NameError) { ::Result }
    end

    test 'the side effects (Context)' do
      assert_raises(NameError) { ::Context }

      BCDD::Result.config.constant_alias.enable!('Context')

      assert_same(BCDD::Result::Context, ::Context)
    ensure
      BCDD::Result.config.constant_alias.disable!('Context')

      assert_raises(NameError) { ::Context }
    end

    test 'the side effects (BCDD::Context)' do
      assert_raises(NameError) { ::BCDD::Context }

      BCDD::Result.config.constant_alias.enable!('BCDD::Context')

      assert_same(BCDD::Result::Context, ::BCDD::Context)
    ensure
      BCDD::Result.config.constant_alias.disable!('BCDD::Context')

      assert_raises(NameError) { ::BCDD::Context }
    end
  end
end
