# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::Expectations::MixinConstantsTest < Minitest::Test
  class IncludingInClass
    include BCDD::Result::Expectations.mixin
  end

  module IncludingInModule
    include BCDD::Result::Expectations.mixin
  end

  class ExtendingInClass
    extend BCDD::Result::Expectations.mixin
  end

  module ExtendingInModule
    extend BCDD::Result::Expectations.mixin
  end

  test 'BCDD::Result::Expectations.mixin sets a constant in all classes/modules' do
    assert IncludingInClass.const_defined?(:ResultExpectationsMixin, false)

    assert IncludingInModule.const_defined?(:ResultExpectationsMixin, false)

    assert ExtendingInClass.const_defined?(:ResultExpectationsMixin, false)

    assert ExtendingInModule.const_defined?(:ResultExpectationsMixin, false)
  end
end
