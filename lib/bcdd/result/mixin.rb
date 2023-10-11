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
        def Continue(value)
          Success(:continued, value)
        end
      end

      OPTIONS = { Continue: Continuable }.freeze

      def self.options(names)
        Array(names).filter_map { |name| OPTIONS[name] }
      end
    end
  end

  def self.mixin(with: nil)
    addons = Mixin::Addons.options(with)

    mod = Module.new
    mod.send(:include, Mixin::Methods)
    mod.send(:include, *addons) unless addons.empty?
    mod
  end

  private_constant :Mixin
end
