# frozen_string_literal: true

require 'singleton'

class BCDD::Result
  class Config
    require_relative 'config/constant_alias'
    require_relative 'config/pattern_matching'

    include Singleton

    attr_reader :pattern_matching, :constant_alias

    def initialize
      @constant_alias = ConstantAlias.new
      @pattern_matching = PatternMatching.new
    end

    def freeze
      constant_alias.freeze
      pattern_matching.freeze

      super
    end
  end
end
