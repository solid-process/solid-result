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

    def ==(other)
      self.class == other.class && type == other.type && value == other.value
    end
    alias eql? ==

    def hash
      [self.class, type, value].hash
    end
  end
end
