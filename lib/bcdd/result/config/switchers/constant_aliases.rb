# frozen_string_literal: true

class BCDD::Result
  class Config
    module ConstantAliases
      MAPPING = {
        'Result' => { target: ::Object, name: :Result, value: ::BCDD::Result },
        'Context' => { target: ::Object, name: :Context, value: ::BCDD::Result::Context },
        'BCDD::Context' => { target: ::BCDD, name: :Context, value: ::BCDD::Result::Context }
      }.transform_values!(&:freeze).freeze

      OPTIONS = MAPPING.to_h do |option_name, mapping|
        affects = mapping.fetch(:target).name.freeze

        [option_name, { default: false, affects: [affects].freeze }]
      end.freeze

      Listener = ->(option_name, bool) do
        mapping = MAPPING.fetch(option_name)

        target, name, value = mapping.fetch_values(:target, :name, :value)

        defined = target.const_defined?(name, false)

        bool ? defined || target.const_set(name, value) : defined && target.send(:remove_const, name)
      end

      def self.switcher
        Switcher.new(options: OPTIONS, listener: Listener)
      end
    end

    private_constant :ConstantAliases
  end
end
