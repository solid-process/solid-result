# frozen_string_literal: true

require_relative 'result/version'
require_relative 'result/error'

module BCDD
  class Result
    attr_reader :type, :value

    def initialize(type:, value:)
      @type = type.to_sym
      @value = value
    end
  end
end
