# frozen_string_literal: true

require 'test_helper'

class Solid::Result::Expectations::MixinConstantsTest < Minitest::Test
  class IncludingInClass
    include Solid::Result::Expectations.mixin
  end

  module IncludingInModule
    include Solid::Result::Expectations.mixin
  end

  class ExtendingInClass
    extend Solid::Result::Expectations.mixin
  end

  module ExtendingInModule
    extend Solid::Result::Expectations.mixin
  end

  test 'Solid::Result::Expectations.mixin sets a constant in all classes/modules' do
    assert IncludingInClass.const_defined?(:ResultExpectationsMixin, false)

    assert IncludingInModule.const_defined?(:ResultExpectationsMixin, false)

    assert ExtendingInClass.const_defined?(:ResultExpectationsMixin, false)

    assert ExtendingInModule.const_defined?(:ResultExpectationsMixin, false)
  end
end
