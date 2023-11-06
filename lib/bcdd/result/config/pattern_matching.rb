# frozen_string_literal: true

class BCDD::Result
  class Config
    class PatternMatching
      module Option
        LIST = [
          NIL_AS_VALID_VALUE_CHECKING = :nil_as_valid_value_checking
        ].freeze

        AFFECTS = {
          NIL_AS_VALID_VALUE_CHECKING => %w[
            BCDD::Result::Expectations
            BCDD::Result::Context::Expectations
          ]
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

      def enable!(*names)
        set_many(names, to: true)
      end

      def disable!(*names)
        set_many(names, to: false)
      end

      private

      def set_many(names, to:)
        option_required!(names)

        names.each { |name| set_one(name, to) }

        options.slice(*names)
      end

      def set_one(name, boolean)
        case name
        when Option::NIL_AS_VALID_VALUE_CHECKING
          _options[name] = boolean
        else
          option_invalid!(name)
        end
      end

      AVAILABLE_OPTIONS = "Available options: #{Option::LIST.map(&:inspect).join(', ')}"

      def option_required!(names)
        raise ::ArgumentError, "One or more options required. #{AVAILABLE_OPTIONS}" if names.empty?
      end

      def option_invalid!(name)
        raise ::ArgumentError, "Invalid option: #{name.inspect}. #{AVAILABLE_OPTIONS}"
      end
    end

    private_constant :PatternMatching
  end
end
