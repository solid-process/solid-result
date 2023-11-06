# frozen_string_literal: true

class BCDD::Result
  class Config
    class Exposable
      module Option
        LIST = [
          RESULT = 'Result'
        ].freeze

        AFFECTS = {
          RESULT => %w[Object]
        }.transform_values!(&:freeze).freeze

        MAPPING = {
          RESULT => { target: ::Object, name: :Result, value: ::BCDD::Result }
        }.transform_values!(&:freeze).freeze
      end

      attr_reader :_options

      private :_options

      def initialize
        @_options = Option::LIST.to_h { [_1, false] }
      end

      def freeze
        _options.freeze
        super
      end

      def options
        Option::AFFECTS.to_h { |name, affects| [name, { enabled: _options[name], affects: affects }] }
      end

      def enabled?(name)
        _options[name] || false
      end

      def enable!(names)
        enable_many(names, to: true)
      end

      def disable!(names)
        enable_many(names, to: false)
      end

      private

      def enable_many(names, to:)
        option_required!(names)

        names.each { |name| enable_one(name, to) }

        options.slice(*names)
      end

      def enable_one(option_name, boolean)
        mapping = Option::MAPPING.fetch(option_name)

        target, name, value = mapping.fetch_values(:target, :name, :value)

        enable_one!(boolean, target: target, name: name, value: value)

        _options[name] = boolean
      rescue ::KeyError
        option_invalid!(name)
      end

      def enable_one!(boolean, target:, name:, value:)
        defined = target.const_defined?(name, false)

        boolean ? defined || target.const_set(name, value) : defined && target.send(:remove_const, name)
      end

      AVAILABLE_OPTIONS = "Available options: #{Option::LIST.map(&:inspect).join(', ')}"

      def option_required!(names)
        raise ::ArgumentError, "One or more options required. #{AVAILABLE_OPTIONS}" if names.empty?
      end

      def option_invalid!(name)
        raise ::ArgumentError, "Invalid option: #{name.inspect}. #{AVAILABLE_OPTIONS}"
      end
    end

    private_constant :Exposable
  end
end
