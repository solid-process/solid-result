# frozen_string_literal: true

class BCDD::Result::Context
  module Mixin
    Factory = BCDD::Result::Mixin::Factory

    module Methods
      def Success(type, **value)
        _ResultAs(Success, type, value)
      end

      def Failure(type, **value)
        _ResultAs(Failure, type, value)
      end

      private def _ResultAs(kind_class, type, value, halted: nil)
        kind_class.new(type: type, value: value, subject: self, halted: halted)
      end
    end

    module Addons
      module Continuable
        def Success(type, **value)
          _ResultAs(Success, type, value, halted: true)
        end

        private def Continue(**value)
          _ResultAs(Success, :continued, value)
        end
      end

      OPTIONS = { continue: Continuable }.freeze

      def self.options(config_flags)
        ::BCDD::Result::Config::Options.addon(map: config_flags, from: OPTIONS)
      end
    end
  end

  def self.mixin_module
    Mixin
  end

  def self.result_factory
    ::BCDD::Result::Context
  end

  private_class_method :mixin_module, :result_factory
end
