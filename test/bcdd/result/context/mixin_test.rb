# frozen_string_literal: true

require 'test_helper'

class BCDD::Result::Context
  class MixinTest < Minitest::Test
    class ClassWithAccumulatorEnabled
      include BCDD::Result::Context.mixin
    end

    class SingletonClassWithoutAccumulatorEnabled
      extend BCDD::Result::Context.mixin
    end

    module ModuleWithoutAccumulatorEnabled
      include BCDD::Result::Context.mixin
    end

    module SingletonModuleWithoutAccumulatorEnabled
      extend BCDD::Result::Context.mixin
    end

    test 'enables BCDD::Result::Context::Accumulator when included in a class' do
      assert ClassWithAccumulatorEnabled < Mixin::Methods

      assert ClassWithAccumulatorEnabled < Accumulator::Enabled
    end

    test 'does not enable BCDD::Result::Context::Accumulator when extended a class' do
      assert SingletonClassWithoutAccumulatorEnabled.singleton_class < Mixin::Methods

      refute SingletonClassWithoutAccumulatorEnabled.singleton_class < Accumulator::Enabled
    end

    test 'does not enable BCDD::Result::Context::Accumulator when included in a module' do
      assert ModuleWithoutAccumulatorEnabled < Mixin::Methods

      refute ModuleWithoutAccumulatorEnabled < Accumulator::Enabled
    end

    test 'does not enable BCDD::Result::Context::Accumulator when extended a module' do
      assert SingletonModuleWithoutAccumulatorEnabled.singleton_class < Mixin::Methods

      refute SingletonModuleWithoutAccumulatorEnabled.singleton_class < Accumulator::Enabled
    end
  end
end
