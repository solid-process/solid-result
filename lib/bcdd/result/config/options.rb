# frozen_string_literal: true

class BCDD::Result
  class Config
    module Options
      def self.with_defaults(all_flags, config:)
        all_flags ||= {}

        default_flags = Config.instance.to_h.fetch(config)

        config_flags = all_flags.fetch(config, {})

        default_flags.merge(config_flags).slice(*default_flags.keys)
      end

      def self.filter_map(all_flags, config:, from:)
        with_defaults(all_flags, config: config)
          .filter_map { |name, truthy| from[name] if truthy }
      end

      def self.addon(map:, from:)
        filter_map(map, config: :addon, from: from)
      end
    end
  end
end
