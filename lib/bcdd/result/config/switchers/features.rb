# frozen_string_literal: true

class BCDD::Result
  class Config
    module Features
      OPTIONS = {
        expectations: {
          default: true,
          affects: %w[BCDD::Result::Expectations BCDD::Context::Expectations]
        },
        transitions: {
          default: true,
          affects: %w[BCDD::Result BCDD::Context BCDD::Result::Expectations BCDD::Context::Expectations]
        },
        and_then!: {
          default: false,
          affects: %w[BCDD::Result BCDD::Context BCDD::Result::Expectations BCDD::Context::Expectations]
        }
      }.transform_values!(&:freeze).freeze

      Listener = ->(option_name, _bool) do
        Thread.current[Transitions::THREAD_VAR_NAME] = nil if option_name == :transitions
      end

      def self.switcher
        Switcher.new(options: OPTIONS, listener: Listener)
      end
    end

    private_constant :Features
  end
end
