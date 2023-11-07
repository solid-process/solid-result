# frozen_string_literal: true

class BCDD::Result::Context
  module Mixin
    Factory = BCDD::Result::Mixin::Factory

    module Methods
      def Success(type, **value)
        Success.new(type: type, value: value, subject: self)
      end

      def Failure(type, **value)
        Failure.new(type: type, value: value, subject: self)
      end
    end

    module Addons
      module Continuable
        private def Continue(**value)
          Success.new(type: :continued, value: value, subject: self)
        end
      end

      OPTIONS = { continue: Continuable }.freeze

      def self.options(names)
        ::BCDD::Result::Config::Options.filter(names, OPTIONS)
      end
    end
  end

  def self.mixin_module
    Mixin
  end

  private_class_method :mixin_module
end
