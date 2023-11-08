# frozen_string_literal: true

class BCDD::Result
  class Config
    module Options
      UnwrapValueFromOptions = ->(flags, options, config_category, (config_name, default_config)) do
        flag_enabled = flags.dig(config_category, config_name)

        options.dig(config_category, config_name) if flag_enabled.nil? ? default_config : flag_enabled
      end.curry

      MapOptionsWithDefaults = ->(options) do
        default_options = Config.instance.options

        defaults = default_options.slice(*options.keys).transform_values(&:to_h)

        return defaults unless defaults.empty?

        raise ArgumentError, "Invalid options: #{options.keys}. Valid ones: #{default_options.keys}"
      end

      def self.unwrap(flags:, options:)
        flags ||= {}

        flags.is_a?(::Hash) or raise ArgumentError, "expected a Hash[Symbol, bool], got #{flags.inspect}"

        options_with_defaults = MapOptionsWithDefaults[options]

        unwrap_value_from_options = UnwrapValueFromOptions[flags, options]

        options_with_defaults.flat_map do |config_category, default_configs|
          default_configs.filter_map(&unwrap_value_from_options[config_category])
        end
      end
    end
  end
end
