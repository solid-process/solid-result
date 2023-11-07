# frozen_string_literal: true

class BCDD::Result
  module Mixin
    module Factory
      def self.module!
        ::Module.new do
          def self.included(base); base.const_set(:ResultMixin, self); end
          def self.extended(base); base.const_set(:ResultMixin, self); end
        end
      end
    end

    module Methods
      def Success(type, value = nil)
        Success.new(type: type, value: value, subject: self)
      end

      def Failure(type, value = nil)
        Failure.new(type: type, value: value, subject: self)
      end
    end

    module Addons
      module Continuable
        private def Continue(value)
          Success(:continued, value)
        end
      end

      OPTIONS = { continue: Continuable }.freeze

      def self.options(names)
        Config::Options.filter(names, OPTIONS)
      end
    end
  end

  def self.mixin(config: nil)
    addons = mixin_module::Addons.options(config)

    mod = mixin_module::Factory.module!
    mod.send(:include, mixin_module::Methods)
    mod.send(:include, *addons) unless addons.empty?
    mod
  end

  def self.mixin_module
    Mixin
  end

  private_class_method :mixin_module
end
