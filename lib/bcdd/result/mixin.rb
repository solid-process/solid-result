# frozen_string_literal: true

class BCDD::Result
  module Mixin
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

      OPTIONS = { Continue: Continuable }.freeze

      def self.options(names)
        Array(names).filter_map { |name| OPTIONS[name] }
      end
    end

    def self.module!
      ::Module.new do
        def self.included(base); base.const_set(:ResultMixin, self); end
        def self.extended(base); base.const_set(:ResultMixin, self); end
      end
    end
  end

  def self.mixin(with: nil)
    addons = Mixin::Addons.options(with)

    mod = Mixin.module!
    mod.send(:include, Mixin::Methods)
    mod.send(:include, *addons) unless addons.empty?
    mod
  end
end
