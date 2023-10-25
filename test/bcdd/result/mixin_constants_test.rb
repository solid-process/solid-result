# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::MixinConstantsTest < Minitest::Test
  class IncludingInClass
    include BCDD::Result.mixin
  end

  module IncludingInModule
    include BCDD::Result.mixin
  end

  class ExtendingInClass
    extend BCDD::Result.mixin
  end

  module ExtendingInModule
    extend BCDD::Result.mixin
  end

  test 'BCDD::Result.mixin sets a constant in all classes/modules' do
    assert IncludingInClass.const_defined?(:ResultMixin, false)

    assert IncludingInModule.const_defined?(:ResultMixin, false)

    assert ExtendingInClass.const_defined?(:ResultMixin, false)

    assert ExtendingInModule.const_defined?(:ResultMixin, false)
  end
end
