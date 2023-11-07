# frozen_string_literal: true

require 'singleton'

require_relative 'config/options'
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

    def self.freeze; instance.freeze; end
    def self.constant_alias; instance.constant_alias; end
    def self.pattern_matching; instance.pattern_matching; end

    def self.options
      %i[constant_alias pattern_matching]
    end

    def self.inspect
      "#<#{name} options=#{options.inspect}>"
    end

    private_class_method :instance
  end
end
