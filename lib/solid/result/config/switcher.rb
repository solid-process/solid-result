# frozen_string_literal: true

class Solid::Result
  class Config
    class Switcher
      attr_reader :_options, :_affects, :listener

      private :_options, :_affects, :listener

      def initialize(options:, listener: nil)
        @_options = options.transform_values { _1.fetch(:default) }
        @_affects = options.transform_values { _1.fetch(:affects) }
        @listener = listener
      end

      def inspect
        "#<#{self.class.name} options=#{_options.inspect}>"
      end

      def freeze
        _options.freeze
        super
      end

      def to_h
        _options.dup
      end

      def options
        _affects.to_h { |name, affects| [name, { enabled: _options[name], affects: affects }] }
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
        require_option!(names)

        names.each do |name|
          set_one(name, to)

          listener&.call(name, to)
        end

        options.slice(*names)
      end

      def set_one(name, boolean)
        validate_option!(name)

        _options[name] = boolean
      end

      def require_option!(names)
        raise ::ArgumentError, "One or more options required. #{available_options_message}" if names.empty?
      end

      def validate_option!(name)
        return if _options.key?(name)

        raise ::ArgumentError, "Invalid option: #{name.inspect}. #{available_options_message}"
      end

      def available_options_message
        "Available options: #{_options.keys.map(&:inspect).join(', ')}"
      end
    end

    private_constant :Switcher
  end
end
