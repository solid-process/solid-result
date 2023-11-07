# frozen_string_literal: true

class BCDD::Result
  class Config
    module Options
      def self.filter(config, all_options)
        config = Array(config).to_h { [_1, true] } unless config.is_a?(::Hash)

        config.filter_map { |name, boolean| all_options[name] if boolean }
      end
    end
  end
end
