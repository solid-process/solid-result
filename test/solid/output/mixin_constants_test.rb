# frozen_string_literal: true

require 'test_helper'

class Solid::Output::MixinConstantsTest < Minitest::Test
  class IncludingInClass
    include Solid::Output.mixin
  end

  module IncludingInModule
    include Solid::Output.mixin
  end

  class ExtendingInClass
    extend Solid::Output.mixin
  end

  module ExtendingInModule
    extend Solid::Output.mixin
  end

  test 'Solid::Output.mixin sets a constant in all classes/modules' do
    assert IncludingInClass.const_defined?(:ResultMixin, false)

    assert IncludingInModule.const_defined?(:ResultMixin, false)

    assert ExtendingInClass.const_defined?(:ResultMixin, false)

    assert ExtendingInModule.const_defined?(:ResultMixin, false)
  end
end
