# frozen_string_literal: true

require 'test_helper'

class Solid::Output::Expectations::MixinConstantsTest < Minitest::Test
  class IncludingInClass
    include Solid::Output::Expectations.mixin
  end

  module IncludingInModule
    include Solid::Output::Expectations.mixin
  end

  class ExtendingInClass
    extend Solid::Output::Expectations.mixin
  end

  module ExtendingInModule
    extend Solid::Output::Expectations.mixin
  end

  test 'Solid::Output::Expectations.mixin sets a constant in all classes/modules' do
    assert IncludingInClass.const_defined?(:ResultExpectationsMixin, false)

    assert IncludingInModule.const_defined?(:ResultExpectationsMixin, false)

    assert ExtendingInClass.const_defined?(:ResultExpectationsMixin, false)

    assert ExtendingInModule.const_defined?(:ResultExpectationsMixin, false)
  end
end
