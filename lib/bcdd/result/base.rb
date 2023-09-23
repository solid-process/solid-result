# frozen_string_literal: true

module BCDD
  class Result
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

    def value_or(&_block)
      raise NotImplementedError
    end
  end
end
