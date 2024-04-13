# frozen_string_literal: true

require 'test_helper'

class Solid::Result::MixinConstantsTest < Minitest::Test
  class IncludingInClass
    include Solid::Result.mixin
  end

  module IncludingInModule
    include Solid::Result.mixin
  end

  class ExtendingInClass
    extend Solid::Result.mixin
  end

  module ExtendingInModule
    extend Solid::Result.mixin
  end

  test 'Solid::Result.mixin sets a constant in all classes/modules' do
    assert IncludingInClass.const_defined?(:ResultMixin, false)

    assert IncludingInModule.const_defined?(:ResultMixin, false)

    assert ExtendingInClass.const_defined?(:ResultMixin, false)

    assert ExtendingInModule.const_defined?(:ResultMixin, false)
  end
end
