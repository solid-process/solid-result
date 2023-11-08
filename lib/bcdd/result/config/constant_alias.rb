# frozen_string_literal: true

class BCDD::Result
  class Config
    module ConstantAlias
      RESULT = 'Result'

      OPTIONS = {
        RESULT => { default: false, affects: %w[Object] }
      }.transform_values!(&:freeze).freeze

      MAPPING = {
        RESULT => { target: ::Object, name: :Result, value: ::BCDD::Result }
      }.transform_values!(&:freeze).freeze

      Listener = ->(option_name, boolean) do
        mapping = MAPPING.fetch(option_name)

        target, name, value = mapping.fetch_values(:target, :name, :value)

        defined = target.const_defined?(name, false)

        boolean ? defined || target.const_set(name, value) : defined && target.send(:remove_const, name)
      end

      def self.switcher
        Switcher.new(options: OPTIONS, listener: Listener)
      end
    end

    private_constant :ConstantAlias
  end
end
