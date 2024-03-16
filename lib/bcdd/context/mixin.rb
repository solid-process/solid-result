# frozen_string_literal: true

class BCDD::Context
  module Mixin
    Factory = BCDD::Result::Mixin::Factory

    module Methods
      def Success(type, **value)
        _ResultAs(Success, type, value)
      end

      def Failure(type, **value)
        _ResultAs(Failure, type, value)
      end

      private def _ResultAs(kind_class, type, value, terminal: nil)
        kind_class.new(type: type, value: value, source: self, terminal: terminal)
      end
    end

    module Addons
      module Continue
        def Success(type, **value)
          _ResultAs(Success, type, value, terminal: true)
        end

        private def Continue(**value)
          _ResultAs(Success, ::BCDD::Result::IgnoredTypes::CONTINUE, value)
        end
      end

      module Given
        private def Given(*values)
          value = values.map(&:to_h).reduce({}) { |acc, val| acc.merge(val) }

          _ResultAs(Success, ::BCDD::Result::IgnoredTypes::GIVEN, value)
        end
      end

      OPTIONS = { continue: Continue, given: Given }.freeze

      def self.options(config_flags)
        ::BCDD::Result::Config::Options.addon(map: config_flags, from: OPTIONS)
      end
    end
  end

  def self.mixin_module
    Mixin
  end

  def self.result_factory
    ::BCDD::Context
  end

  private_class_method :mixin_module, :result_factory
end
