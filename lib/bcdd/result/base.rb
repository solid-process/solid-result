# frozen_string_literal: true

module BCDD::Result
  class Base
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
      raise Error::NotImplemented
    end

    def ==(other)
      self.class == other.class && type == other.type && value == other.value
    end
    alias eql? ==

    def hash
      [self.class, type, value].hash
    end

    def inspect
      format('#<%<class_name>s type=%<type>p value=%<value>p>', class_name: self.class.name, type: type, value: value)
    end

    alias data value
    alias data_or value_or

    def on(*types)
      raise Error::MissingTypeArgument if types.empty?

      tap { yield(value, type) if expected_type?(types) }
    end

    private

    def expected_type?(types)
      types.any?(type)
    end
  end
end
