# frozen_string_literal: true

require 'singleton'

require_relative 'config/switcher'
require_relative 'config/constant_alias'

class BCDD::Result
  class Config
    include Singleton

    CONSTANT_ALIAS = Switcher.factory(
      options: ConstantAlias::OPTIONS,
      listener: ConstantAlias::Listener
    )

    PATTERN_MATCHING = Switcher.factory(
      options: {
        nil_as_valid_value_checking: %w[
          BCDD::Result::Expectations
          BCDD::Result::Context::Expectations
        ]
      }
    )

    attr_reader :constant_alias, :pattern_matching

    def initialize
      @constant_alias = CONSTANT_ALIAS.call
      @pattern_matching = PATTERN_MATCHING.call
    end

    def freeze
      constant_alias.freeze
      pattern_matching.freeze

      super
    end
  end
end
