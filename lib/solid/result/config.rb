# frozen_string_literal: true

require_relative 'config/options'
require_relative 'config/switcher'
require_relative 'config/switchers/addons'
require_relative 'config/switchers/constant_aliases'
require_relative 'config/switchers/features'
require_relative 'config/switchers/pattern_matching'

class Solid::Result
  class Config
    attr_reader :addon, :feature, :constant_alias, :pattern_matching

    def initialize
      @addon = Addons.switcher
      @feature = Features.switcher
      @constant_alias = ConstantAliases.switcher
      @pattern_matching = PatternMatching.switcher
      @and_then_ = CallableAndThen::Config.new
    end

    def event_logs
      EventLogs::Config.instance
    end

    def and_then!
      @and_then_
    end

    def freeze
      addon.freeze
      feature.freeze
      constant_alias.freeze
      pattern_matching.freeze
      and_then!.freeze
      event_logs.freeze

      super
    end

    def options
      {
        addon: addon,
        feature: feature,
        constant_alias: constant_alias,
        pattern_matching: pattern_matching
      }
    end

    def to_h
      options.transform_values(&:to_h)
    end

    def inspect
      "#<#{self.class.name} " \
        "options=#{options.keys.sort.inspect} " \
        "and_then!=#{and_then!.options.inspect}>"
    end

    @instance = new

    singleton_class.send(:attr_reader, :instance)
  end
end
