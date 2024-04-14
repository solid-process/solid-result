# frozen_string_literal: true

class Solid::Result
  class Config
    module Options
      def self.with_defaults(all_flags, config)
        all_flags ||= {}

        default_flags = Config.instance.to_h.fetch(config)

        config_flags = all_flags.fetch(config, {})

        default_flags.merge(config_flags).slice(*default_flags.keys)
      end

      def self.select(all_flags, config:, from:)
        with_defaults(all_flags, config)
          .filter_map { |name, truthy| [name, from[name]] if truthy }
          .to_h
      end

      def self.addon(map:, from:)
        select(map, config: :addon, from: from)
      end
    end
  end
end
