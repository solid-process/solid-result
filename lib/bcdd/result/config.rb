# frozen_string_literal: true

require 'singleton'

require_relative 'config/options'
require_relative 'config/switcher'
require_relative 'config/constant_alias'

class BCDD::Result
  class Config
    include Singleton

    ADDON = {
      continue: {
        default: false,
        affects: %w[BCDD::Result BCDD::Result::Context BCDD::Result::Expectations BCDD::Result::Context::Expectations]
      }
    }.transform_values!(&:freeze).freeze

    PATTERN_MATCHING = {
      nil_as_valid_value_checking: {
        default: false,
        affects: %w[BCDD::Result::Expectations BCDD::Result::Context::Expectations]
      }
    }.transform_values!(&:freeze).freeze

    attr_reader :addon, :constant_alias, :pattern_matching

    def initialize
      @addon = Switcher.new(options: ADDON)
      @constant_alias = ConstantAlias.switcher
      @pattern_matching = Switcher.new(options: PATTERN_MATCHING)
    end

    def freeze
      addon.freeze
      constant_alias.freeze
      pattern_matching.freeze

      super
    end

    def options
      {
        addon: addon,
        constant_alias: constant_alias,
        pattern_matching: pattern_matching
      }
    end

    def to_h
      options.transform_values(&:to_h)
    end

    def inspect
      "#<#{self.class.name} options=#{options.keys.inspect}>"
    end

    private_constant :ADDON, :PATTERN_MATCHING
  end
end
