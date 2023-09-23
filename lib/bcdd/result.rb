# frozen_string_literal: true

require_relative 'result/version'
require_relative 'result/error'

module BCDD
  class Result
    require_relative 'result/failure'
    require_relative 'result/success'

    attr_reader :type, :value

    def initialize(type:, value:)
      @type = type.to_sym
      @value = value
    end

    def success?(_type = nil)
      raise Error::NotImplemented
    end

    def failure?(_type = nil)
      raise Error::NotImplemented
    end
  end
end
